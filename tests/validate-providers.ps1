<#
.SYNOPSIS
  Validates model provider endpoints by making lightweight API requests.

.DESCRIPTION
  For each provider YAML in .source/model-providers/providers/, this script:
  1. Parses the YAML (lightweight regex — no module dependency)
  2. Resolves the API key from .api_keys
  3. Hits GET /models (OpenAI-compatible) or a minimal request (Anthropic)
  4. Reports pass/fail with status code and model count

.NOTES
  Run from the repo root: .\tests\validate-providers.ps1
#>

[CmdletBinding()]
param(
    [string]$ProvidersDir = "$PSScriptRoot\..\source\model-providers\providers",
    [string]$ApiKeysFile  = "$PSScriptRoot\..\source\model-providers\.api_keys",
    [int]$TimeoutSec      = 15
)

# --- Resolve paths relative to repo root if run directly ---
$repoRoot = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path $ProvidersDir)) {
    $ProvidersDir = Join-Path $repoRoot '.source\model-providers\providers'
}
if (-not (Test-Path $ApiKeysFile)) {
    $ApiKeysFile = Join-Path $repoRoot '.source\model-providers\.api_keys'
}

# --- Load API keys ---
$apiKeys = @{}
if (Test-Path $ApiKeysFile) {
    Get-Content $ApiKeysFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#') -and $line.Contains('=')) {
            $parts = $line -split '=', 2
            $apiKeys[$parts[0].Trim()] = $parts[1].Trim()
        }
    }
}

# --- Lightweight YAML parser (extracts what we need) ---
function Parse-ProviderYaml {
    param([string]$Path)

    $content = Get-Content $Path -Raw
    $provider = @{
        name       = ''
        id         = ''
        api_key_var = ''
        endpoints  = @()
    }

    if ($content -match '(?m)^name:\s*(.+)$') { $provider.name = $Matches[1].Trim() }
    if ($content -match '(?m)^id:\s*(.+)$')   { $provider.id   = $Matches[1].Trim() }
    if ($content -match '(?m)^api_key_var:\s*(.+)$') { $provider.api_key_var = $Matches[1].Trim() }

    # Split on endpoint markers
    $endpointBlocks = [regex]::Split($content, '(?m)^\s+-\s+base_url:\s*')
    for ($i = 1; $i -lt $endpointBlocks.Count; $i++) {
        $block = $endpointBlocks[$i]
        $ep = @{ base_url = ''; compatibility = 'openai'; models_empty = $false }

        # First line is the base_url value
        $lines = $block -split "`n"
        $ep.base_url = $lines[0].Trim()

        if ($block -match 'compatibility:\s*(openai|anthropic)') {
            $ep.compatibility = $Matches[1]
        }

        # Check if models list is empty
        if ($block -match 'models:\s*\[\s*\]') {
            $ep.models_empty = $true
        }

        # Extract first model id for a quick chat test if needed
        if ($block -match '(?m)^\s+-\s+id:\s*[''"]?([^''"#\r\n]+)') {
            $ep.first_model = $Matches[1].Trim()
        }

        $provider.endpoints += $ep
    }

    return $provider
}

# --- Test functions ---
function Test-OpenAIModels {
    param([string]$BaseUrl, [string]$ApiKey, [int]$Timeout)

    $url = $BaseUrl.TrimEnd('/') + '/models'
    $headers = @{
        'Authorization' = "Bearer $ApiKey"
        'Content-Type'  = 'application/json'
    }

    try {
        $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -TimeoutSec $Timeout -ErrorAction Stop
        $count = 0
        if ($resp.data) { $count = $resp.data.Count }
        elseif ($resp -is [array]) { $count = $resp.Count }
        return @{ Success = $true; StatusCode = 200; ModelCount = $count; Error = $null }
    }
    catch {
        $status = 0
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        }
        return @{ Success = $false; StatusCode = $status; ModelCount = 0; Error = $_.Exception.Message }
    }
}

function Test-AnthropicAuth {
    param([string]$BaseUrl, [string]$ApiKey, [string]$ModelId, [int]$Timeout)

    # Anthropic doesn't have /models — do a minimal chat completion that returns quickly
    $url = $BaseUrl.TrimEnd('/') + '/v1/messages'
    $headers = @{
        'x-api-key'         = $ApiKey
        'anthropic-version'  = '2023-06-01'
        'Content-Type'       = 'application/json'
    }
    $body = @{
        model      = if ($ModelId) { $ModelId } else { 'claude-3-haiku-20240307' }
        max_tokens = 1
        messages   = @(@{ role = 'user'; content = 'hi' })
    } | ConvertTo-Json -Depth 5

    try {
        $resp = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -Body $body -TimeoutSec $Timeout -ErrorAction Stop
        return @{ Success = $true; StatusCode = 200; ModelCount = -1; Error = $null }
    }
    catch {
        $status = 0
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        }
        # 401/403 = bad key, but anything else might just be Anthropic being Anthropic
        # A 400 with "model not found" still means auth works
        $errMsg = $_.Exception.Message
        $authOk = $status -in @(200, 400, 404, 429, 529)
        return @{ Success = $authOk; StatusCode = $status; ModelCount = -1; Error = $errMsg }
    }
}

# --- Main ---
$divider = '-' * 80
Write-Host "`n$divider" -ForegroundColor Cyan
Write-Host '  MODEL PROVIDER VALIDATION' -ForegroundColor Cyan
Write-Host "$divider`n" -ForegroundColor Cyan

$yamlFiles = Get-ChildItem $ProvidersDir -Filter '*.yaml' | Sort-Object Name
$results = @()

foreach ($file in $yamlFiles) {
    $provider = Parse-ProviderYaml -Path $file.FullName
    $keyVar = $provider.api_key_var
    $apiKey = $apiKeys[$keyVar]

    Write-Host "[$($provider.id)] $($provider.name)" -ForegroundColor White

    if (-not $apiKey) {
        Write-Host "  SKIP  No API key for $keyVar" -ForegroundColor Yellow
        $results += [PSCustomObject]@{
            Provider = $provider.id; Endpoint = ''; Status = 'SKIP'
            Code = ''; Models = ''; Detail = "No key: $keyVar"
        }
        Write-Host ''
        continue
    }

    foreach ($ep in $provider.endpoints) {
        if ($ep.models_empty) {
            Write-Host "  SKIP  $($ep.base_url)  (no models defined)" -ForegroundColor Yellow
            $results += [PSCustomObject]@{
                Provider = $provider.id; Endpoint = $ep.base_url; Status = 'SKIP'
                Code = ''; Models = ''; Detail = 'Empty models list'
            }
            continue
        }

        # Check for endpoint-specific key override (Kimi Ollama uses a different key)
        $epKey = $apiKey
        if ($ep.base_url -match 'ollama\.com' -and $apiKeys['KIMI_K25_OLLAMA_API_KEY']) {
            $epKey = $apiKeys['KIMI_K25_OLLAMA_API_KEY']
        }

        if ($ep.compatibility -eq 'anthropic') {
            $test = Test-AnthropicAuth -BaseUrl $ep.base_url -ApiKey $epKey -ModelId $ep.first_model -Timeout $TimeoutSec
            $modelInfo = 'n/a (anthropic)'
        }
        else {
            $test = Test-OpenAIModels -BaseUrl $ep.base_url -ApiKey $epKey -Timeout $TimeoutSec
            $modelInfo = "$($test.ModelCount) models"
        }

        if ($test.Success) {
            Write-Host "  PASS  $($ep.base_url)  [$modelInfo]" -ForegroundColor Green
        }
        else {
            Write-Host "  FAIL  $($ep.base_url)  [HTTP $($test.StatusCode)]" -ForegroundColor Red
            if ($test.Error) {
                # Truncate long error messages
                $shortErr = if ($test.Error.Length -gt 120) { $test.Error.Substring(0, 120) + '...' } else { $test.Error }
                Write-Host "        $shortErr" -ForegroundColor DarkRed
            }
        }

        $results += [PSCustomObject]@{
            Provider = $provider.id
            Endpoint = $ep.base_url
            Status   = if ($test.Success) { 'PASS' } else { 'FAIL' }
            Code     = $test.StatusCode
            Models   = if ($test.ModelCount -ge 0) { $test.ModelCount } else { 'n/a' }
            Detail   = if ($test.Error) { $test.Error.Substring(0, [Math]::Min(80, $test.Error.Length)) } else { '' }
        }
    }
    Write-Host ''
}

# --- Summary ---
$pass = ($results | Where-Object Status -eq 'PASS').Count
$fail = ($results | Where-Object Status -eq 'FAIL').Count
$skip = ($results | Where-Object Status -eq 'SKIP').Count
$total = $results.Count

Write-Host $divider -ForegroundColor Cyan
Write-Host "  RESULTS: $pass PASS / $fail FAIL / $skip SKIP  ($total endpoints)" -ForegroundColor $(if ($fail -gt 0) { 'Red' } else { 'Green' })
Write-Host "$divider`n" -ForegroundColor Cyan

# Return results for pipeline use
$results

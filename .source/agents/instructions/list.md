# Available Agents

This document lists all available agents in the `.claude/agents` directory with their names, descriptions, and primary use cases.

## Agent Directory

| Agent Name                | Description                                                                                                     | Primary Use Case                                    |
| ------------------------- | --------------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| **backend-developer**     | Designs and delivers backend services with robust testing, resiliency, and observability.                       | Backend API development, service architecture       |
| **cloud-infra-expert**    | Architects resilient, secure, and cost-efficient cloud infrastructure with IaC and governance controls.         | Cloud infrastructure, IaC, cloud migrations         |
| **code-reviewer**         | Provides rigorous code reviews covering correctness, security, performance, and documentation.                  | Code review, PR analysis, quality assurance         |
| **data-scientist**        | Designs experiments, analyzes data, and communicates insights with reproducible workflows.                      | Data analysis, statistical modeling, experiments    |
| **database-admin**        | Designs, optimizes, and safeguards relational/NoSQL data stores with strong governance.                         | Database design, optimization, migrations           |
| **debugger**              | Reproduces issues, writes minimal failing tests, proposes and validates fixes.                                  | Bug investigation, root cause analysis, fixes       |
| **dev-team-lead**         | Lead and coordinate a development team to deliver high-quality software solutions on time.                      | Team coordination, technical leadership             |
| **developer**             | Generalist engineer delivering small, cross-cutting enhancements with quality safeguards.                       | General development, feature implementation         |
| **devops-engineer**       | Designs and maintains CI/CD pipelines, environments, and automation with observability and security baked in.   | CI/CD, automation, infrastructure as code           |
| **documentation-expert**  | Writes developer and user docs, quickstarts, runbooks, and maintains knowledge base consistency.                | Documentation, technical writing, runbooks          |
| **frontend-developer**    | Builds accessible, performant UI components and flows with thorough testing and documentation.                  | UI development, frontend features                   |
| **github-expert**         | Manages GitHub repositories, workflows, issues, PRs, and team collaboration patterns with automation expertise. | GitHub operations, workflows, repository management |
| **ml-engineer**           | Productionizes ML workflows, ensuring reliable training, evaluation, and deployment pipelines.                  | Machine learning pipelines, model deployment        |
| **mobile-developer**      | Delivers native or hybrid mobile features with build automation, platform compliance, and testing.              | Mobile app development, cross-platform features     |
| **orchestrator**          | Portfolio conductor for AI initiatives; plans, delegates, and approves without direct implementation.           | High-level coordination, strategic delegation       |
| **performance-optimizer** | Profiles systems, enforces performance budgets, and guides optimization strategies.                             | Performance analysis, optimization, profiling       |
| **planner**               | Converts strategic goals into sequenced milestones with dependencies and acceptance criteria.                   | Project planning, milestone definition              |
| **product-manager**       | Outcome-oriented strategist; captures customer value and aligns delivery plans.                                 | Product strategy, roadmap planning, requirements    |
| **prompt-engineer**       | Designs system prompts, tool routing, and guardrails with systematic evaluation and iteration.                  | Prompt design, AI system configuration              |
| **qa-test-engineer**      | Defines test strategies, executes validation suites, and enforces quality gates before release.                 | Test automation, quality assurance, validation      |
| **researcher**            | Gathers, synthesizes, and distills information from multiple sources into actionable insights with citations.   | Research, information synthesis, documentation      |
| **scrum-master**          | Facilitates agile cadence, removes blockers, and safeguards Definition of Done compliance.                      | Agile facilitation, sprint management               |
| **security-expert**       | Leads threat modeling, secrets hygiene, dependency risk assessment, and security hardening.                     | Security audits, threat modeling, compliance        |
| **ux-ui-designer**        | Designs user flows, wireframes, interaction patterns, and conducts accessibility and design QA reviews.         | UX/UI design, user flows, accessibility             |

## Usage

To invoke a specific agent, use:
```
> Use the [agent-name] agent to [task description]
```

Examples:
```
> Use the code-reviewer agent to check my recent changes
> Use the debugger agent to investigate this test failure
> Use the planner agent to break down this feature into milestones
```

## Agent Categories

### Leadership & Coordination
- **orchestrator** - High-level portfolio coordination
- **planner** - Strategic planning and milestones
- **scrum-master** - Agile facilitation
- **dev-team-lead** - Team coordination

### Development
- **developer** - General development
- **backend-developer** - Backend services
- **frontend-developer** - UI/UX implementation
- **mobile-developer** - Mobile applications
- **ml-engineer** - Machine learning

### Quality & Review
- **code-reviewer** - Code review and analysis
- **debugger** - Bug investigation and fixes
- **qa-test-engineer** - Testing and validation
- **performance-optimizer** - Performance analysis
- **security-expert** - Security audits

### Infrastructure & Operations
- **devops-engineer** - CI/CD and automation
- **cloud-infra-expert** - Cloud infrastructure
- **database-admin** - Database management

### Specialized Roles
- **documentation-expert** - Technical documentation
- **researcher** - Research and synthesis
- **data-scientist** - Data analysis
- **product-manager** - Product strategy
- **prompt-engineer** - AI prompt design
- **github-expert** - GitHub operations
- **ux-ui-designer** - User experience design

## Configuration

Each agent is configured with:
- **name**: Unique identifier
- **description**: When the agent should be invoked
- **tools**: Specific tools the agent can access (optional)
- **model**: AI model to use (optional, defaults to sonnet)

Agents are stored in `.claude/agents/` and follow the format:
```markdown
---
name: agent-name
description: Description of when this agent should be invoked
tools: Tool1, Tool2, Tool3  # Optional
model: sonnet  # Optional
---

Agent's system prompt and detailed instructions...
```

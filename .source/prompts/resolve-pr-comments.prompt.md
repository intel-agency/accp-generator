---
agent: agent
---

# Inputs
- pr_num: The number of the pull request to address comments for.

# Prompt
In PR  #${pr_num}, please address the following review comments:

1. Resolved issues identifid in Claude Code Reviews
2. Resolve all Copilot Review comments

After commiting changes for each comment, add reply with explanation of changes and then resolve the review comment thread.
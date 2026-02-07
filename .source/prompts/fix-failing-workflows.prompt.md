---
name: fix-failing-workflows
description: Describe when to use this prompt
argument-hint: $workflow_names = comma or space separated list of 0 or more workflow names
---
Repeat until workflows succeed:

1. check for failing workflows
    a. if ${workflow_names} is empty, check all workflows
    b. if ${workflow_names} is not empty, check only the specified workflows
2. for each failing workflow, check the logs to identify the cause of failure
3. fix the identified issues in the codebase
4. commit and push the changes to trigger the workflows again
5. minotor the workflow progress
6. if any workflows fail again, repeat the process from step 1

For multple workflows, prioritize fixing the ones that are critical for the project or have the most impact on the development process.
- Work through one workflow at a time to ensure that each issue is properly addressed before moving on to the next one.
- If the same issue is causing multiple workflows to fail, focus on fixing that issue first to resolve multiple failures at once.
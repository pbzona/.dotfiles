---
description: Generate a weekly session report (shortcut for /session-report "last 7 days")
agent: session-reporter
subtask: true
---

Generate a session report for the last 7 days.

**Time Period:** last 7 days
**Directory Filter:** $1
**Output Location:** $2

If no directory is specified, include all directories.
If no output location is specified, write to `./_reports/` in the current directory.

Follow the full instructions in the session-reporter agent.

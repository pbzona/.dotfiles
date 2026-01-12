---
description: Generate a summary report of OpenCode sessions for a time period
agent: session-reporter
subtask: true
---

Generate a comprehensive session report based on the following parameters:

**Time Period:** $1
**Directory Filter:** $2
**Output Location:** $3

If no time period is specified, default to "last 7 days".
If no directory is specified, include all directories.
If no output location is specified, write to `./_reports/` in the current directory.

## Instructions

1. First, ensure the OpenCode server is running. Check if `http://localhost:4096/doc` is accessible.

   - If not running, start it with: `opencode serve --port 4096 &`
   - Wait a few seconds for it to initialize

2. Calculate the timestamp for the time period:

   - "today" = midnight today
   - "yesterday" = midnight yesterday
   - "last 7 days" or "this week" = 7 days ago at midnight
   - "last monday" or "since monday" = most recent Monday at midnight
   - "last 2 weeks" = 14 days ago
   - "this month" = first day of current month
   - Custom date like "2026-01-05" = that date at midnight

3. Query the OpenCode API:

   - `GET /session?start={timestamp_ms}&limit=200` to get sessions
   - If directory filter provided: `GET /session?directory={dir}&start={timestamp_ms}&limit=200`
   - For each main session (where parentID is null), get messages: `GET /session/{id}/message`

4. Analyze the sessions and create a report with:

   - Executive summary with completion statistics
   - Sessions grouped by project/directory
   - For each session: title, date, files changed, key work done
   - Summary of themes and patterns across sessions

5. Write the report to the specified output location as markdown.

## Example Usage

```
/session-report "last 7 days"
/session-report "since monday" "/Users/phil/server"
/session-report "2026-01-05 to 2026-01-10" "" "./reports/"
```

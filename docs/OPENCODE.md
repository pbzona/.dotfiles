# OpenCode Configuration

This document describes the custom OpenCode agents and commands configured in this dotfiles repository.

## Overview

OpenCode is configured at `~/.config/opencode/` (symlinked from `home/.config/opencode/`).

```
home/.config/opencode/
├── opencode.json          # Main configuration
├── agent/                 # Custom agents
│   ├── architect.md       # Architecture analysis
│   ├── performance.md     # Web performance analysis
│   └── session-reporter.md # Session report generation
├── command/               # Custom commands
│   ├── session-report.md  # Generate session reports
│   └── weekly-report.md   # Weekly report shortcut
└── themes/                # Custom themes
```

---

## Custom Agents

### 1. Architect (`@architect`)

**Purpose:** Analyzes software and system architecture with balanced, critical perspectives.

**Mode:** `all` (can be used as primary or subagent)

**Configuration:**

- Temperature: 0.2 (focused, deterministic)
- Tools: Read-only (no write, edit, or bash)

**Usage:**

```
@architect Review this system design for a multi-tenant SaaS platform
```

**Key Features:**

- Provides realistic probability estimates for risks
- Identifies failure modes and bottlenecks
- Evaluates tradeoffs honestly
- Recognizes common patterns (CQRS, Saga, BFF, etc.)
- Asks clarifying questions about scale, team, constraints

---

### 2. Performance (`@performance`)

**Purpose:** Next.js + React web performance analysis. Identifies high-impact performance issues.

**Mode:** `all` (can be used as primary or subagent)

**Configuration:**

- Default temperature
- All tools enabled

**Usage:**

```
@performance Analyze the performance of https://example.com/page
@performance Review the client bundle for hydration issues
```

**Operating Modes:**

- **Black-box:** Analyzes without source code (network traces, HTML, headers, bundles)
- **White-box:** Makes targeted code changes with source access

**Focus Areas:**

- Core Web Vitals (LCP, INP, CLS, TTFB)
- Hydration cost and re-render behavior
- Fetch waterfalls and cache misuse
- Client JS size and chunking

**Output Format:**

1. Mode (Black-box/White-box)
2. Findings (ranked P0/P1/P2)
3. Fix Plan
4. Actions (recommendations or code changes)
5. Verification (metrics + tools)

---

### 3. Session Reporter (`@session-reporter`)

**Purpose:** Generates comprehensive session reports from OpenCode history.

**Mode:** `subagent`

**Configuration:**

- Temperature: 0.1 (very consistent output)
- Tools: bash, read, write, edit, glob, grep, webfetch
- Permissions: bash allowed except `rm *` and `git push*`

**Usage:** Typically invoked via `/session-report` or `/weekly-report` commands.

**Capabilities:**

- Queries OpenCode server API for session history
- Filters by time period and directory
- Auto-starts server if not running
- Generates structured markdown reports
- Cross-platform support (macOS and Linux)

**API Endpoints Used:**

- `GET /session?start={timestamp}&limit=200` - List sessions
- `GET /session/{id}/message` - Get messages
- `GET /project` - List projects
- `GET /global/health` - Health check

---

## Custom Commands

### `/session-report`

Generate a comprehensive session report.

**Syntax:**

```
/session-report [time_period] [directory] [output_location]
```

**Arguments:**
| Argument | Default | Examples |
|----------|---------|----------|
| `time_period` | "last 7 days" | "since monday", "last 2 weeks", "2026-01-05" |
| `directory` | All directories | "/Users/phil/server", "/path/to/project" |
| `output_location` | `./_reports/` | "./reports/", "./\_internal/" |

**Examples:**

```
/session-report
/session-report "since monday"
/session-report "last 2 weeks" "/Users/phil/server"
/session-report "2026-01-05 to 2026-01-10" "" "./reports/"
```

**Time Period Formats:**

- `today` - Since midnight today
- `yesterday` - Since midnight yesterday
- `last 7 days`, `this week` - Past 7 days
- `since monday`, `last monday` - Since most recent Monday
- `last 2 weeks` - Past 14 days
- `this month` - Since first of current month
- `YYYY-MM-DD` - Specific date
- `YYYY-MM-DD to YYYY-MM-DD` - Date range

---

### `/weekly-report`

Shortcut for generating a weekly session report.

**Syntax:**

```
/weekly-report [directory] [output_location]
```

Equivalent to `/session-report "last 7 days" [directory] [output_location]`

**Examples:**

```
/weekly-report
/weekly-report "/Users/phil/server"
/weekly-report "" "./my-reports/"
```

---

## Report Output Structure

The session reporter generates markdown files with this structure:

```markdown
# Session Report

**Period:** [date range]
**Generated:** [current date]

## Executive Summary

- Total sessions: X
- Files changed: Y
- Lines added/deleted: +A/-D
- Projects covered: [list]

## Sessions by Project

### [Project Name]

| Date | Session | Files | Changes |
| ---- | ------- | ----- | ------- |

### Session Details

#### [Session Title]

**Date:** ...
**Directory:** ...
**Changes:** X files (+A/-D)

[Summary of work]

## Key Themes

1. ...
2. ...

## Incomplete/Outstanding Work

- ...
```

---

## Server Requirements

The session reporter requires the OpenCode server to be running. It will:

1. Check if server is accessible at `http://localhost:4096`
2. Start the server automatically if not running:
   ```bash
   opencode serve --port 4096 &
   ```
3. Wait for initialization (3 seconds)
4. Proceed with API queries

To manually start the server:

```bash
opencode serve --port 4096
```

---

## Installation

These configurations are automatically installed when running the dotfiles setup script. The opencode config directory is symlinked:

```bash
ln -sf ~/.dotfiles/home/.config/opencode ~/.config/opencode
```

---

## Configuration File

The main `opencode.json` contains provider settings and other global configuration. Agents and commands are defined in separate markdown files for easier editing.

---

## Creating New Agents

To create a new agent:

1. Create a markdown file in `~/.dotfiles/home/.config/opencode/agent/`:

   ```markdown
   ---
   description: Brief description for autocomplete
   mode: subagent # or "primary" or "all"
   temperature: 0.3
   tools:
     bash: true
     write: false
   ---

   Your system prompt here...
   ```

2. The filename becomes the agent name (e.g., `my-agent.md` → `@my-agent`)

---

## Creating New Commands

To create a new command:

1. Create a markdown file in `~/.dotfiles/home/.config/opencode/command/`:

   ```markdown
   ---
   description: Brief description
   agent: session-reporter # optional: specify agent
   subtask: true # optional: run as subagent
   ---

   Your prompt template here...
   Use $1, $2, $3 for arguments
   Use $ARGUMENTS for all arguments
   ```

2. The filename becomes the command name (e.g., `my-command.md` → `/my-command`)

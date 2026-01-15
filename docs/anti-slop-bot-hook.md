# Setting Up a Global Git Pre-Commit Anti-Slop Bot

A global git pre-commit hook using Claude Code CLI to review code before every commit.

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- `jq` for JSON parsing (`brew install jq`)

## Quick Start

```bash
mkdir -p ~/.config/git/hooks
# Copy the hook script below to ~/.config/git/hooks/pre-commit
chmod +x ~/.config/git/hooks/pre-commit
git config --global core.hooksPath ~/.config/git/hooks
```

---

## When NOT to Use This Hook

Consider disabling for:

- **Rapid prototyping** - When iterating quickly and quality isn't the priority yet
- **Large migrations** - Auto-generated code or bulk refactors (use `ANTI_SLOP_MAX_LINES`)
- **Offline work** - No internet means Claude can't run
- **CI/CD pipelines** - The hook is for local dev; CI should have its own checks
- **Pair programming** - When commits are frequent WIP checkpoints

### Disable Per-Project

Create `.git/hooks/anti-slop-disable` in any repo to skip the check:

```bash
touch .git/hooks/anti-slop-disable
```

Or set in your shell before commits:

```bash
export ANTI_SLOP=0  # Disable for entire session
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ANTI_SLOP` | `1` | Set to `0` to disable entirely |
| `ANTI_SLOP_TIMEOUT` | `90` | Seconds before timeout |
| `ANTI_SLOP_MODEL` | `opus` | Model: `opus`, `sonnet`, `haiku` |
| `ANTI_SLOP_MAX_LINES` | `2000` | Max diff lines (skips if exceeded) |

---

## The Complete Hook Script

Save as `~/.config/git/hooks/pre-commit`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

# Per-project disable check
[[ -f .git/hooks/anti-slop-disable ]] && exit 0

# Run local hook first
LOCAL_HOOK="$(git rev-parse --git-dir)/hooks/pre-commit"
[[ -x "$LOCAL_HOOK" ]] && { "$LOCAL_HOOK" "$@" || exit 1; }

# Config
TIMEOUT_SECONDS="${ANTI_SLOP_TIMEOUT:-90}"
MODEL="${ANTI_SLOP_MODEL:-opus}"
MAX_DIFF_LINES="${ANTI_SLOP_MAX_LINES:-2000}"
ENABLED="${ANTI_SLOP:-1}"

[[ "$ENABLED" == "0" ]] && exit 0
command -v claude &>/dev/null || exit 0

CODE_EXT='(js|jsx|ts|tsx|py|go|rs|java|kt|swift|c|cpp|h|hpp|rb|php|cs|scala|sh|bash|zsh|vue|svelte|astro|md|json|yaml|yml|toml)'
STAGED=$(git diff --cached --name-only --diff-filter=ACMR | grep -E "\.${CODE_EXT}$" || true)
[[ -z "$STAGED" ]] && exit 0

DIFF=$(git diff --cached -U5)
DIFF_LINES=$(echo "$DIFF" | wc -l | tr -d ' ')
[[ "$DIFF_LINES" -gt "$MAX_DIFF_LINES" ]] && exit 0

echo -e "\033[0;35m    🤖 ANTI-SLOP BOT 2000\033[0m"
echo -e "\033[0;36m📋 Reviewing $(echo "$STAGED" | wc -l | tr -d ' ') file(s), ${DIFF_LINES} lines...\033[0m"
```

Then add the Claude invocation:

```bash
SYSTEM_PROMPT='You are the ANTI-SLOP BOT 2000, an elite code quality guardian.

Your mission: Detect and REJECT low-quality "slop" code before it pollutes the codebase.

## What is "Slop"?
- Security vulnerabilities (SQL injection, XSS, command injection, hardcoded secrets)
- Obvious bugs (null derefs, off-by-one errors, race conditions, unclosed resources)
- Dead code (unused imports, unreachable code, commented-out blocks)
- Console.log/print debugging left in production code
- TODO/FIXME/HACK comments in new code
- Empty catch blocks that swallow errors
- Sensitive data exposure (API keys, passwords, tokens)

## What is NOT Slop (ignore):
- Style preferences (not a linter)
- Missing docs, test coverage, architecture decisions
- Existing code that was not changed

## Output: JSON only
APPROVED: {"status":"APPROVED","message":"..."}
REJECTED: {"status":"REJECTED","summary":"...","issues":[{"severity":"critical|high|medium","file":"...","line":42,"type":"security|bug|debug|secrets","message":"...","suggestion":"..."}]}

RULES: Only analyze + lines. Do not invent issues. Be strict but fair.'

JSON_SCHEMA='{"type":"object","properties":{"status":{"type":"string","enum":["APPROVED","REJECTED"]},"message":{"type":"string"},"summary":{"type":"string"},"issues":{"type":"array","items":{"type":"object","properties":{"severity":{"type":"string","enum":["critical","high","medium"]},"file":{"type":"string"},"line":{"type":"integer"},"type":{"type":"string"},"message":{"type":"string"},"suggestion":{"type":"string"}},"required":["severity","file","type","message","suggestion"]}}},"required":["status"]}'

PROMPT="Review this git diff. PROJECT: $(basename $(pwd))
FILES: ${STAGED}
DIFF:
\`\`\`diff
${DIFF}
\`\`\`"

TEMP=$(mktemp); trap "rm -f $TEMP" EXIT

timeout "${TIMEOUT_SECONDS}s" claude -p \
    --setting-sources "" \
    --mcp-config '{"mcpServers":{}}' \
    --strict-mcp-config \
    --add-dir "$(pwd)" \
    --model "$MODEL" \
    --system-prompt "$SYSTEM_PROMPT" \
    --output-format json \
    --json-schema "$JSON_SCHEMA" \
    "$PROMPT" > "$TEMP" 2>&1 || { echo -e "\033[1;33m⚠️ Timeout/error, allowing commit\033[0m"; exit 0; }

RESULT=$(cat "$TEMP")
if echo "$RESULT" | jq -e '.structured_output' &>/dev/null; then
    JSON=$(echo "$RESULT" | jq '.structured_output')
else
    JSON="$RESULT"
fi

STATUS=$(echo "$JSON" | jq -r '.status // "UNKNOWN"')

if [[ "$STATUS" == "APPROVED" ]]; then
    echo -e "\033[0;32m✅ APPROVED: $(echo "$JSON" | jq -r '.message')\033[0m"
    exit 0
elif [[ "$STATUS" == "REJECTED" ]]; then
    echo -e "\033[0;31m🚫 REJECTED: $(echo "$JSON" | jq -r '.summary')\033[0m"
    echo "$JSON" | jq -r '.issues[]? | "  [\(.severity|ascii_upcase)] \(.file):\(.line//"?") - \(.message)\n    💡 \(.suggestion)"'
    echo -e "\033[1;33mUse 'git commit --no-verify' to bypass\033[0m"
    exit 1
fi
exit 0
```

---

## Claude CLI Flags

| Flag | Purpose |
|------|---------|
| `-p` | Print mode (non-interactive) |
| `--setting-sources ""` | Ignore all settings files |
| `--mcp-config '{}'` | No MCP servers |
| `--strict-mcp-config` | Enforce empty MCP |
| `--add-dir` | Give Claude project context |
| `--model` | Which model to use |
| `--output-format json` | JSON output |
| `--json-schema` | Enforce response structure |

---

## Bypass Options

```bash
git commit --no-verify -m "msg"  # Skip once
git commit -n -m "msg"           # Short form
ANTI_SLOP=0 git commit -m "msg"  # Disable for command
touch .git/hooks/anti-slop-disable  # Disable per-project
```

---

## Hook Execution Order

```
1. .git/hooks/pre-commit  ← Local (husky, lint-staged)
2. ANTI-SLOP BOT          ← Claude check
```

Local hooks run first for fast failures before the Claude API call.


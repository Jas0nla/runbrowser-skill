---
name: runbrowser
description: Install, connect, and use RunBrowser so an agent can control the user's existing Chrome session from the CLI. Use this when the goal is Chrome as the execution layer and a CLI agent such as Codex or Claude as the orchestrator, especially for logged-in sites, real browser state, and websites that are brittle under generic automation.
---

# RunBrowser

Use this skill when you want an agent to control the user's already-running Chrome instead of launching a separate browser profile.

This is the right tool when:

- the site depends on the user's real Chrome login state, cookies, or extensions
- a normal Playwright session is not enough because it loses the user's real browser context
- the task should be driven from a CLI agent such as `codex` or `claude`

This is not the right tool when:

- a clean isolated browser is preferred
- the task is simple scraping and does not need the user's live session
- the user has not installed the Chrome extension yet

## Installation

### 1. Install the CLI

Prefer the scoped package because that is the package we have verified locally:

```bash
npm i -g @jiweiyuan/runbrowser
```

After install, confirm the command exists:

```bash
runbrowser --help
```

### 2. Download the Chrome extension source

RunBrowser's npm package installs the CLI only. The Chrome extension must be built from the upstream repo.

```bash
git clone https://github.com/runbrowser/runbrowser.git
cd runbrowser
pnpm install
```

Or use the bundled setup script in this skill:

```bash
./scripts/setup_extension.sh
```

To choose a custom local folder:

```bash
./scripts/setup_extension.sh /path/to/runbrowser-upstream
```

### 3. Build the extension

The extension depends on a local workspace package, so this build order matters:

```bash
pnpm --filter vite-plugin-extension-reload build
pnpm run build:extension
```

The extension folder you load into Chrome should be:

```text
packages/extension/dist
```

If you used the bundled setup script, it prints the exact local `dist` path after a successful build.

### 4. Load the extension into Chrome

In Chrome:

1. Open `chrome://extensions`
2. Turn on `Developer mode`
3. Click `Load unpacked`
4. Select `packages/extension/dist`
5. Click the RunBrowser extension icon on the target tab until it turns green

The extension connects Chrome to the local relay on `localhost:19988`.

## Minimal verification

Create a session:

```bash
runbrowser session new
```

List sessions:

```bash
runbrowser session list
```

Navigate the connected tab:

```bash
runbrowser navigate https://example.com -s 1
```

Take a semantic snapshot:

```bash
runbrowser snapshot -s 1
```

If this works, the browser bridge is alive and the agent can start using Chrome as its execution layer.

## High-value commands

Use these first before dropping to raw JS:

```bash
runbrowser navigate https://example.com -s 1
runbrowser snapshot -s 1
runbrowser click @e5 -s 1
runbrowser fill @e3 "hello world" -s 1
runbrowser select @e8 "California" -s 1
runbrowser wait @e5 -s 1
runbrowser screenshot -s 1 --output shot.png
runbrowser get text @e5 -s 1
runbrowser eval 'document.title' -s 1
```

Use `snapshot` often. It gives stable element refs such as `@e5`, which are usually more reliable than guessing selectors.

## Agent integration

Install the shared skill into agent environments:

```bash
npx -y skills add runbrowser/runbrowser --yes --global
```

This makes the skill available to common local agents such as Codex, Claude Code, Cursor, Goose, and OpenClaw when the global skills installer supports them.

## Workflow pattern

Use this pattern:

1. Ensure Chrome is already open on the target site
2. Turn the extension green on the active tab
3. Create or list the RunBrowser session
4. Use `snapshot` to get refs
5. Use high-level commands first
6. Only use `eval` or `cdp` when high-level commands are not enough

## Common pitfalls

### CLI installed but extension missing

This is the most common failure mode. `npm i -g @jiweiyuan/runbrowser` installs the CLI, not the extension build output.

### Old examples use outdated session commands

Prefer:

```bash
runbrowser session new
runbrowser session list
```

not older variants like:

```bash
runbrowser session-new
```

### Extension is loaded but not connected

If the extension is not green, the CLI may wait for a session or report no live browser.

### Real page state matters

RunBrowser is strongest when the user is already logged in and the target tab is already in the real Chrome profile they care about.

## When to fall back

Fall back to ordinary Playwright when:

- the user does not want to load a Chrome extension
- a clean reproducible browser is more important than real logged-in state
- CI or headless automation is the real goal

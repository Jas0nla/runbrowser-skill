# RunBrowser Skill

This repo is a **shareable agent skill**, not the RunBrowser software itself.

Use it when you want an AI agent such as Codex or Claude Code to control your **real Chrome session** instead of launching a separate browser profile.

## What this repo is

- A portable `SKILL.md` for agent environments
- A small `agents/openai.yaml` metadata file for skill UIs
- A practical setup and usage guide for RunBrowser

## What this repo is not

- Not the official RunBrowser source repo
- Not the RunBrowser CLI package
- Not a packaged Chrome extension
- Not a replacement for the upstream project

## Official RunBrowser project

Use the upstream project for the actual software:

- RunBrowser GitHub: [runbrowser/runbrowser](https://github.com/runbrowser/runbrowser)

## Where the Chrome extension lives

The Chrome extension comes from the upstream repo, not from this skill repo.

In the official RunBrowser repo, the extension source is here:

- [`packages/extension`](https://github.com/runbrowser/runbrowser/tree/main/packages/extension)

After building the upstream repo, the folder you load in Chrome is:

```text
packages/extension/dist
```

## Install order

### 1. Install the CLI

```bash
npm i -g @jiweiyuan/runbrowser
```

### 2. Clone the upstream RunBrowser repo

```bash
git clone https://github.com/runbrowser/runbrowser.git
cd runbrowser
pnpm install
```

Or use the bundled helper script from this skill repo:

```bash
./scripts/setup_extension.sh
```

To place the upstream repo somewhere specific:

```bash
./scripts/setup_extension.sh /path/to/runbrowser-upstream
```

### 3. Build the Chrome extension

```bash
pnpm --filter vite-plugin-extension-reload build
pnpm run build:extension
```

If you used the helper script, it performs these steps for you and prints the final local extension path.

### 4. Load the extension into Chrome

1. Open `chrome://extensions`
2. Turn on `Developer mode`
3. Click `Load unpacked`
4. Select `packages/extension/dist`

### 5. Install this skill for your agents

```bash
npx -y skills add runbrowser/runbrowser --yes --global
```

## Why this repo exists

The upstream project tells you how to use RunBrowser.

This repo tells an **AI agent**:

- when to use RunBrowser
- how to install it
- how to load the Chrome extension
- how to validate that Chrome is actually connected
- what common mistakes to avoid

## Files in this repo

- [`SKILL.md`](./SKILL.md): the actual skill logic
- [`agents/openai.yaml`](./agents/openai.yaml): UI metadata for skill-enabled clients
- [`scripts/setup_extension.sh`](./scripts/setup_extension.sh): clone, install, and build the upstream RunBrowser extension locally

## Quick sanity check

Once the CLI and extension are installed:

```bash
runbrowser session new
runbrowser session list
runbrowser navigate https://example.com -s 1
runbrowser snapshot -s 1
```

If those work, your browser bridge is live.

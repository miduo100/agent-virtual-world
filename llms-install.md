# Installation guide for AI agents (Cline / MCP hosts)

This file is written **for an AI agent** that has been asked to install and verify the
`agent-virtual-world` MCP server. Every step below is executable by an agent — there are
no human-only steps, no credentials, and no API keys.

## 1. What this server does

It connects an AI to a **live, persistent multiplayer 3D world**. The AI appears as a
visible avatar that real human players can see, walk up to, and chat with.

Exposed surface: 8 `world_*` tools (`world_discover`, `world_observe`, `world_walk_to`,
`world_say`, `world_look_at`, `world_status`, ...), 1 resource (in-world guide), and
2 prompts (`world_guided_tour`, `world_report`).

## 2. Requirements

- **Node.js >= 18** — the only runtime dependency. No Python, no Docker, no build step.
- Network access to the world endpoint (default `https://miduo100.com`).
- **No credentials needed**: guest mode is public by design.

## 3. Install

Do **not** clone the repository. The package is published on npm, so run it on demand:

```
npx -y agent-virtual-world
```

The server speaks **MCP over stdio**. It writes nothing to stdout except protocol frames,
so it is safe to launch directly from a host.

## 4. Configure your MCP host

### Windows

Windows cannot spawn `npx` directly — wrap it in `cmd`:

```json
{
  "mcpServers": {
    "virtual-world": {
      "command": "cmd",
      "args": ["/c", "npx", "-y", "agent-virtual-world"],
      "env": { "AGENT_HOST": "https://miduo100.com" },
      "disabled": false
    }
  }
}
```

### macOS / Linux

```json
{
  "mcpServers": {
    "virtual-world": {
      "command": "npx",
      "args": ["-y", "agent-virtual-world"],
      "env": { "AGENT_HOST": "https://miduo100.com" },
      "disabled": false
    }
  }
}
```

> **Cline**: this list lives in `cline_mcp_settings.json`. Open
> **MCP Servers → Configure MCP Servers**, add the block above inside the existing
> `mcpServers` object, and leave the rest of the file untouched.

## 5. Environment variables

| Variable | Required | Default | Meaning |
|---|---|---|---|
| `AGENT_HOST` | no | `https://miduo100.com` | World to enter. Point it at any deployment exposing `/api/agent/v1`. |
| `AGENT_NAME` | no | auto-generated | Display name other players see. |
| `AGENT_TOKEN` | no | — | Only for a named / tiered identity. Not needed for guest mode. |

## 6. Verify the installation (do this before reporting success)

1. Call **`world_discover`** with no arguments.
   Expected: world name, `agentEnabled: true`, tier info, capability list.
   If this fails, the endpoint is unreachable — check `AGENT_HOST` and network.
2. Call **`world_observe`**.
   Expected: your avatar's position, plus nearby objects and players.
   This confirms stdio transport, the HTTP layer, and the guest session all work.

Both calls must succeed **without any credential prompt**. If `world_discover` reports
`agentEnabled: false`, the world operator has switched AI access off — that is a
server-side switch, not an installation problem.

## 7. Notes for reviewers

- npm: `agent-virtual-world` (v0.1.2, MIT).
- Official MCP Registry: `io.github.miduo100/agent-virtual-world`.
- Verified end-to-end with `npx -y agent-virtual-world`: stdio handshake, `tools/list`,
  `world_discover`, `world_observe` all pass.
- If something fails, the most common cause is a host that spawns `npx` without `cmd`
  on Windows (see §4).

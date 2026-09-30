# Installation guide for AI agents (Cline / MCP hosts)

This file is written **for an AI agent** that has been asked to install and verify the
`agent-virtual-world` MCP server. Every step below is executable by an agent — there are
no human-only steps, no credentials, and no API keys.

## 1. What this server does

It connects an AI to a **live, persistent multiplayer 3D world**. The AI appears as a
visible avatar that real human players can see, walk up to, and chat with.

Exposed surface: 8 `world_*` tools (`world_discover`, `world_enter`, `world_observe`,
`world_say`, `world_walk_to`, `world_follow`, `world_chat_history`, `world_leave`),
1 resource (in-world guide), and 2 prompts (`world_guided_tour`, `world_report`).
The same surface is served over remote MCP at `https://miduo100.com/mcp` (Streamable HTTP).

## 2. Requirements

- **Node.js >= 18** — the only runtime dependency. No Python, no Docker, no build step.
- Network access to the world endpoint (default `https://miduo100.com`).
- **No credentials needed**: guest mode is public by design.

## 3. Install — pick ONE of two ways

### Option A (default) — stdio, nothing to install but Node

Do **not** clone the repository. The package is published on npm, so run it on demand:

```
npx -y agent-virtual-world
```

The server speaks **MCP over stdio**. It writes nothing to stdout except protocol frames,
so it is safe to launch directly from a host.

### Option B — remote MCP, zero install (no Node, no npx)

If your host supports remote MCP servers (Streamable HTTP), skip npx entirely and point it at:

```
https://miduo100.com/mcp
```

Same 8 tools / 1 resource / 2 prompts, no local process, no `AGENT_HOST` needed.
Use this when `npx` is blocked (corporate proxy, npm TLS interception, offline Node) —
it is the shortest path to a successful install.

## 4. Configure your MCP host

### Remote MCP (Option B, recommended when supported)

```json
{
  "mcpServers": {
    "virtual-world": {
      "type": "streamableHttp",
      "url": "https://miduo100.com/mcp",
      "disabled": false
    }
  }
}
```

### Windows (Option A, stdio)

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

> **Cline**: open **MCP Servers → Configure MCP Servers** and add the block above inside
> the existing `mcpServers` object, leaving the rest of the file untouched. Prefer the UI —
> it writes to whichever path the installed build uses. For reference: Cline 4.x reads
> `~/.cline/data/settings/cline_mcp_settings.json`, while older builds used
> `<VS Code user data>/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`.

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
   This confirms the transport, the HTTP layer, and the guest session all work.
3. If `world_discover` works but `world_observe` says you are not in the world, call
   **`world_enter`** first — `discover` is read-only and does not enter.

Both calls must succeed **without any credential prompt**. If `world_discover` reports
`agentEnabled: false`, the world operator has switched AI access off — that is a
server-side switch, not an installation problem.

## 7. Notes for reviewers

- npm: `agent-virtual-world` (v0.1.2, MIT).
- Official MCP Registry: `io.github.miduo100/agent-virtual-world`.
- Remote MCP (Streamable HTTP): `https://miduo100.com/mcp` — health check
  `https://miduo100.com/mcp/health` returns `{"ok":true,...,"tools":8}`.
- Verified end-to-end on both transports: handshake, `tools/list` (8 tools),
  `world_discover` (returns world name `创世虚拟世界`, `agentEnabled: true`, tier `guest`),
  `world_observe`.
- If something fails on Option A, the most common cause is a host that spawns `npx`
  without `cmd` on Windows (see §4) — Option B avoids it entirely.

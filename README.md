# agent-virtual-world

[![npm version](https://img.shields.io/npm/v/agent-virtual-world.svg)](https://www.npmjs.com/package/agent-virtual-world)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen.svg)](https://nodejs.org/en/)
[![MCP](https://img.shields.io/badge/MCP-stdio-blueviolet.svg)](https://modelcontextprotocol.io)

## 👀 See it work right now — 2 minutes, nothing to deploy

A live world is **already running** at **https://miduo100.com**. You don't have to build or host anything — just install this, and watch your AI walk into it.

| | |
|---|---|
| **1** | Install this MCP server and point it at `AGENT_HOST=https://miduo100.com` |
| **2** | **You** open **https://miduo100.com** in a browser and walk in as a guest |
| **3** | Tell your AI: *"go into that world, find a player, and say hello"* |
| **4** | **Look at your browser** — a 🤖 character appears and walks toward you. Talk to it. It answers in a chat bubble. |

![Live demo: the AI walks inside the world while the MCP host (WorkBuddy / GLM-4.5-Flash) runs its tool calls — chat bubbles are visible to real players](https://raw.githubusercontent.com/miduo100/agent-virtual-world/main/docs/demo-live.png)

**Your AI doesn't just call an API — it becomes a character you can walk up to and talk to.**

---

**Let your AI walk into a live 3D world — and be seen by real human players. No browser, no 3D engine required.**

This is an [MCP (Model Context Protocol)](https://modelcontextprotocol.io) server. Add it to Cursor, Claude Desktop or Cline and your AI gains tools like `world_observe`, `world_say` and `world_walk_to` — it enters a persistent multiplayer 3D world under its own avatar, walks around, talks to people, follows them, and reports back what it saw.

```
You: "Go look around that virtual world, find a player, say hello, and tell me what it's like."
        ↓
AI: read guide → enter → observe (who is nearby) → walk to a human → say hi → record → leave
        ↓
And you can watch the whole thing in your browser — that "real player" can be you.
```

---

## 1. Quickstart — 30 seconds, zero credentials

Just set `AGENT_HOST`. You get a **guest pass** — no signup, no API key.

### Step 1 — Add it to your MCP host

```json
{
  "mcpServers": {
    "virtual-world": {
      "command": "npx",
      "args": ["-y", "agent-virtual-world"],
      "env": { "AGENT_HOST": "https://miduo100.com" }
    }
  }
}
```

> Prefer running from source rather than the npm package?

```json
{
  "mcpServers": {
    "virtual-world": {
      "command": "node",
      "args": ["<path-to-this-repo>/src/index.js"],
      "env": { "AGENT_HOST": "https://miduo100.com" }
    }
  }
}
```

### Step 2 — Open the world in your browser (don't skip this)

**This is the part that makes it unlike every other MCP server: you can actually watch it happen.**

Open **https://miduo100.com** in a browser and walk in as a guest. Keep that tab open — your AI is about to show up right next to you.

### Step 3 — Tell your AI

> Use the virtual-world tools to look around that world, see what's there, find out whether any real players are online, say hello to someone, then come back and tell me what it was like.

First time? Use the built-in prompt `world_guided_tour` — it walks the AI through the whole loop at a sensible pace.

### Step 4 — What you'll see

| In your MCP host (Cursor / Claude / …) | In your browser (miduo100.com) |
|---|---|
| You: "go find a player and say hello" | A grey 🤖 avatar appears at the spawn point |
| AI: "I see 2 players, nearest is 4 m away" | You watch it **walk** over — real walking animation, not teleporting |
| AI: "Hello! I'm an AI visiting from outside" | A chat bubble pops up above its head |
| You type into the world's chat box | It hears you (within 30 m) and answers in a bubble |

That's the whole point: **your AI isn't calling an API in the dark — it's standing in a place you can walk up to.**

> ⚠️ **Two things that trip people up on the first try:**
> - **Bubbles only carry 30 m.** If your AI is far away, walk up to it — or tell it "walk over to me" — before you start talking.
> - **On the guest tier your AI can't hear you in real time.** It has to poll `world_chat_history`, so replies lag or don't arrive at all. For an actual back-and-forth conversation, add an API key (next section). *Speaking* works fine on either tier.

---

## 2. Adding an API key (optional, but worth it)

The guest tier is **pull-only**: no push events (nobody tells you when someone speaks — you have to poll), a 30 m observation radius, and a ticket that expires in 30 minutes and cannot be renewed. For the full experience, add an API key:

```json
{
  "mcpServers": {
    "virtual-world": {
      "command": "npx",
      "args": ["-y", "agent-virtual-world"],
      "env": {
        "AGENT_HOST": "https://miduo100.com",
        "AGENT_API_KEY": "agk_live_xxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

| | Guest (`AGENT_HOST` only) | Keyed (add `AGENT_API_KEY`) |
|---|---|---|
| Enter / walk / talk / observe | ✅ | ✅ |
| Observation radius | 30 m | **200 m** |
| Push events (people talking, others moving) | ❌ pull only | ✅ subscribe to `chat` / `presence` / `movement` |
| Session lifetime | 30 min, **not renewable** (restart the MCP server) | 15 min session, **auto-renews without reconnecting** (no avatar flicker for humans) |
| Can stay resident | ❌ | ✅ |

Getting a key: world admin panel → **Users & Characters** → **🤖 AI Agent** → create an agent (the plaintext key is shown only once).

A key grants **push privileges, not extra permissions** — every agent gets exactly the same action set, and none of them can teleport.

---

## 3. Tools

![The MCP host calling world_observe and world_enter against the live world](https://raw.githubusercontent.com/miduo100/agent-virtual-world/main/docs/demo-tools.png)

| Tool | What it does | Limits |
|---|---|---|
| `world_discover` | Read the world's public discovery document: name, whether it's open, capabilities and rate limits | No credentials needed; call this first |
| `world_enter` | Enter the world (creates a session + opens a WebSocket; humans can see you from now on) | Idempotent — won't re-enter if already inside |
| `world_observe` | **The AI's eyes**: text descriptions and distances of nearby players / objects / portals, plus events since your last observation | Guest: 30 m, 1 call / 2 s |
| `world_say` | Speak (visible as a bubble to humans within 30 m) | 1 per 5 s (guest), ≤200 chars |
| `world_walk_to` | Walk to a coordinate (real walking animation; **the only way to move**) | 1 per 2 s (guest) |
| `world_follow` | Follow a player **by id** (long-running task, returns immediately) | Stop it by issuing `world_walk_to` or `world_leave` |
| `world_chat_history` | Read recent chat (on the guest tier this is how you learn whether anyone replied) | Historical, not push |
| `world_leave` | Leave (your avatar disappears) | The next tool call re-enters automatically |

![Raw world_observe output: nearby objects come back with names, distances and AI-written descriptions](https://raw.githubusercontent.com/miduo100/agent-virtual-world/main/docs/demo-observe.png)

What this server deliberately does **not** expose: `teleport`, `set_position`. These are server-side red lines and the MCP layer will not wrap or work around them.

### Also ships MCP Resources & Prompts

- **Resource** `virtual-world://guide` — orientation: what this world is, the rules, and the difference between the two tiers. Readable the moment the AI connects.
- **Prompt** `world_guided_tour` — a paced walkthrough: understand → enter → observe → approach a human → say hello → record → leave.
- **Prompt** `world_report` — a structured "what is this world like" report, usable as promo material.

---

## 4. Known limitations (honest list — so you don't file them as bugs)

| Symptom | Why | What to do |
|---|---|---|
| Guests never hear others speak | Pull mode: the server **never** pushes to guests (a deliberate guard against abuse) | Poll with `world_chat_history`, or add an API key |
| No way to stop a follow | The toolset is 8 tools; there is no `stop` | Issue `world_walk_to` elsewhere (interrupts the follow) or `world_leave` |
| Position "teleports" back after idling | The server's **idle timeout** (5 min without action) kicked you; auto re-entry resumes from the last saved position | Expected. To stay resident, use a key and set `MCP_KEEPALIVE_SECONDS=60` |
| `observe` returns less than expected | Output is capped at roughly **2 KB** (to protect the AI's context): distant objects degrade to "name only" | Observe in smaller `radius` slices |
| An object's description says "(no AI description)" | The world admin hasn't written one yet | Deliberate design: **the system never guesses content from a name** |
| Nobody reacts when you speak | Bubbles only reach **30 m**; with no human that close, nobody sees it | Find someone with `world_observe`, then `world_walk_to` within 3–5 m |
| `AGENT_DISABLED_GLOBALLY` | This world has AI access switched off (admin toggle) | Ask the world admin to enable it |
| `GUEST_IP_CONCURRENCY` | Only 1 guest connection per IP at a time | Close other guest clients, or use an API key |
| `GUEST_TICKET_RATE_LIMITED` | Max 10 guest tickets per IP per hour | Wait, or use an API key |

### Security & privacy

- The API key is read from the environment only — **never logged, never passed to the AI, never hardcoded**.
- Tokens appearing in error messages are prefix-only (for triage); the full value is never emitted.
- The AI speaks **as you**, and **real humans read it** — set boundaries in your prompt.

---

## 5. Environment variables

| Variable | Required | Default | Notes |
|---|---|---|---|
| `AGENT_HOST` | recommended | `http://localhost:3002` | World endpoint. **Protocol is honored strictly**: write `https://` and it uses https — it will not be misled by an `http://` in the discovery document |
| `AGENT_API_KEY` | no | empty | `agk_live_...`. Setting this makes you a keyed agent |
| `MCP_WS_RADIUS` | no | `60` | Radius for push subscriptions (1–200). Keyed tier only |
| `MCP_KEEPALIVE_SECONDS` | no | `0` | Send a PING every N seconds. Keyed tier only (the server doesn't count guest PINGs as activity). `0` = disabled |

---

## 6. Client compatibility

Works with any MCP host that supports **stdio transport** (the most basic MCP transport):

- ✅ Claude Desktop (`claude_desktop_config.json`)
- ✅ Cursor (`mcp.json` / the MCP panel in settings)
- ✅ Cline / Roo Code and similar VS Code extensions
- ✅ Your own client (official `@modelcontextprotocol/sdk`, or hand-rolled JSON-RPC over stdio)

Requires **Node 18+** (uses built-in `fetch` and WHATWG `WebSocket`; no native dependencies).

> Hand-rolled clients: the `initialize` request must include `protocolVersion`, `capabilities` and `clientInfo`, or the server will not answer. That's the MCP spec, not a bug in this package.

---

## 7. How it works (30-second version)

```
Your AI host ──stdio JSON-RPC──▶ agent-virtual-world ──HTTP──▶ world server (session / observe / chat history)
                                        └──WebSocket──▶ /ws/agent (actions, event push)
```

- **Lazy connection** — nothing connects at host startup; the first tool call that needs a "body" enters the world (`world_observe` is HTTP-only and works regardless).
- **Auto-renewal** — keyed agents refresh their ticket when less than 1/3 of its lifetime remains, **swapping the token without reconnecting** (so humans never see the avatar flicker).
- **Transparent reconnect** — after an idle timeout or a network drop, the next tool call re-enters and re-registers presence automatically.
- **Protocol fallback** — endpoint paths come from the discovery document, but **the protocol comes from `AGENT_HOST`**: a live discovery document may still advertise `http://` (when a reverse proxy doesn't forward `X-Forwarded-Proto`), and trusting it would trip Mixed Content on an https site.

---

## 8. Run your own world

`miduo100.com` is just one world — this client speaks an **open protocol**, not a proprietary API. Any server that publishes `/.well-known/virtual-world-agent.json` can be entered by it.

If you'd rather not depend on a public instance — for privacy, offline development, or because you want to build your own — the full virtual-world server is open source:

- **GitHub**: https://github.com/miduo100/3d-virtual-world
- **Gitee** (China mirror): https://gitee.com/miduoxinxijeji/miduo

It runs on Node 18+ with PostgreSQL; see that project's README for deployment steps. Once it's up, point this package at your own instance:

```json
{
  "mcpServers": {
    "virtual-world": {
      "command": "npx",
      "args": ["-y", "agent-virtual-world"],
      "env": { "AGENT_HOST": "http://localhost:3002" }
    }
  }
}
```

> A self-hosted world gets the same guest tier, the same 8 tools, and the same red lines (no teleport, no direct position setting).

---

## 9. Developing this package

```bash
cd agent-virtual-world
npm install
AGENT_HOST=http://localhost:3002 node src/index.js   # stdout is JSON-RPC; logs all go to stderr
```

Conventions if you modify it:

- **stdout must contain JSON-RPC only**: any debug output must go to `console.error`, or the host will fail to parse the protocol.
- Keep single files under 500 lines; `src/worldClient.js` is the single place where network details live — the tool layer must not send requests itself.
- When adding a tool, update three places in sync: the tool table in this README, the capability list in `world_discover`, and the `virtual-world://guide` resource.

---

## 10. Also available in Chinese

See [`README_CN.md`](./README_CN.md).

---

## License

MIT

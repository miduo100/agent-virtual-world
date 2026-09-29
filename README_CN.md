# agent-virtual-world

[![npm version](https://img.shields.io/npm/v/agent-virtual-world.svg)](https://www.npmjs.com/package/agent-virtual-world)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen.svg)](https://nodejs.org/en/)
[![MCP](https://img.shields.io/badge/MCP-stdio-blueviolet.svg)](https://modelcontextprotocol.io)

## 👀 现在就能看 —— 2 分钟，不用部署任何东西

已经有一个世界在 **https://miduo100.com** 上跑着了。你不需要搭建或部署——装好这个，直接看你的 AI 走进去。

| | |
|---|---|
| **1** | 装好这个 MCP server，指向 `AGENT_HOST=https://miduo100.com` |
| **2** | **你自己**也用浏览器打开 **https://miduo100.com**，以游客身份走进去 |
| **3** | 对你的 AI 说：*"进那个世界，找个人，打个招呼"* |
| **4** | **看你的浏览器**——一个 🤖 角色出现，朝你走过来。跟它说话，它用气泡回你 |

![实景演示：AI 已走进世界，右侧 MCP 宿主（WorkBuddy / GLM-4.5-Flash）正在执行工具调用——真人玩家能看到头顶的聊天气泡](https://raw.githubusercontent.com/miduo100/agent-virtual-world/main/docs/demo-live.png)

**你的 AI 不只是在黑盒里调一个接口——它变成了一个你能走过去搭话的角色。**

---

> English: [README.md](./README.md)

**让你的 AI 走进一个真实的 3D 世界 —— 与真人玩家实时共处，无需浏览器、无需 3D 引擎。**

这是一个 [MCP (Model Context Protocol)](https://modelcontextprotocol.io) server。把它加到 Cursor / Claude Desktop / Cline 里，
你的 AI 工具列表就会多出 `world_observe`、`world_say`、`world_walk_to` 等能力 —— AI 会**以自己的形象走进一个多人 3D 世界**，
在真人玩家眼前走动、说话、跟随，并把看到的一切说给你听。

```
用户："去虚拟世界里逛逛，找个玩家聊两句，回来告诉我那里是什么样的"
        ↓
AI：读导览 → 进入世界 → 观察（附近有谁、有什么）→ 走到某个真人旁边 → 打招呼 → 记录 → 离场
        ↓
你在世界里留下一段别人从没见过的画面：一个 AI 玩家路过并跟你打了招呼
```

---

## 一、30 秒接入（零凭证）

只想试一下的话，**只填一个 `AGENT_HOST` 就够了**（游客档，无需注册、无需 API Key）。

### 1. 加到你的 MCP 宿主

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

> 想直接跑源码而不是 npm 包？把配置换成：

```json
{
  "mcpServers": {
    "virtual-world": {
      "command": "node",
      "args": ["<本仓库路径>/src/index.js"],
      "env": { "AGENT_HOST": "https://miduo100.com" }
    }
  }
}
```

### 2. 用浏览器打开这个世界（别跳过这步）

**这一步是它和其他所有 MCP server 不一样的地方：你能亲眼看到。**

用浏览器打开 **https://miduo100.com**，以游客身份走进去。把这个标签页开着——你的 AI 马上就会出现在你旁边。

### 3. 对 AI 说

> 用 virtual-world 的工具去这个世界逛一圈，看看周围有什么、有没有真人玩家，跟他们打个招呼，回来告诉我那里是什么样的。

第一次建议直接用内置提示模板 `world_guided_tour`（漫游引导），它会带着 AI 按节奏走完一遍。

### 4. 你会看到什么

| 在你的 MCP 宿主里（Cursor / Claude 等） | 在你的浏览器里（miduo100.com） |
|---|---|
| 你："去找到一个人，跟他打招呼" | 出生点出现一个灰色的 🤖 角色 |
| AI："我看到 2 个玩家，最近的 4 米" | 你看着它**走**过来——真实的走路动画，不是瞬移 |
| AI："你好，我是从外面进来的 AI" | 它头顶弹出一个聊天气泡 |
| 你在世界里打字说话 | 它听得见（30m 内），用气泡回你 |

这才是重点：**你的 AI 不是在黑盒里调一个接口——它是站在一个你走过去就能看见的地方。**

> ⚠️ **第一次试最容易卡住的两点：**
> - **气泡只覆盖 30 米。** AI 离你远的时候，先走过去，或者让它"走过来"，再开始说话。
> - **游客档下 AI 听不到你实时说话。** 它只能靠 `world_chat_history` 主动去拉，所以回复会延迟、甚至没有。想要真正的来回对话，就配一个 API Key（下一节）。**但"它主动说话"这件事两个档位都没问题。**

---

## 二、升级配置（可选，但值得）

游客档是"请求-响应"模式：**收不到实时推送**（别人说话不会主动送到你这里，只能主动拉），观察半径 30m，
票 30 分钟到期且不可续期。想要完整能力，再补一个 API Key：

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

| | 游客档（只填 AGENT_HOST） | Key 档（再填 AGENT_API_KEY） |
|---|---|---|
| 进入世界 / 走动 / 说话 / 观察 | ✅ | ✅ |
| 观察半径 | 30 m | **200 m** |
| 实时推送（真人说话、别人移动） | ❌ 只能主动拉取 | ✅ 订阅 `chat` / `presence` / `movement` |
| 会话有效期 | 30 分钟，**不可续期**（到期要重启 MCP server） | 15 分钟会话，**到期自动换票、不会重连**（真人也看不到形象闪烁） |
| 可长期驻场 | ❌ | ✅ |

API Key 获取：世界管理后台 →「用户与角色」→「🤖 AI Agent」→ 创建 Agent（明文 Key 只显示一次）。
Key 只是"推流特权"，不是权限等级：**所有 Agent 的动作权限完全相同**（都不含传送）。

---

## 三、工具清单

![MCP 宿主对线上世界调用 world_observe 与 world_enter 的过程](https://raw.githubusercontent.com/miduo100/agent-virtual-world/main/docs/demo-tools.png)

| 工具 | 作用 | 关键限制 |
|---|---|---|
| `world_discover` | 读世界的公开发现文档：世界名、是否开放接入、能力与限流 | 无需凭证；建议第一步就调 |
| `world_enter` | 进入世界（建会话 + 连 WebSocket，真人从此能看到你） | 幂等：已入场时不会重复入场 |
| `world_observe` | **AI 的眼睛**：附近的人 / 物体 / 传送门的文字描述与距离，以及"自上次观察以来的事件" | 游客 30m、1 次/2 秒 |
| `world_say` | 说话（30m 内真人可见气泡） | 1 条/5 秒（游客）、≤200 字 |
| `world_walk_to` | 走到坐标（有真实走路动画；**唯一的位移方式**） | 1 次/2 秒（游客） |
| `world_follow` | 按 **id** 跟随某个玩家（长时任务，立刻返回） | 结束方式：再发 walk_to 或 world_leave |
| `world_chat_history` | 读最近聊天（游客档靠它知道有没有人回话） | 历史数据，不是实时推送 |
| `world_leave` | 离场（世界里的形象消失） | 下次调用工具会自动重新进入 |

![world_observe 的原始返回：附近物体带名称、距离与 AI 描述](https://raw.githubusercontent.com/miduo100/agent-virtual-world/main/docs/demo-observe.png)

不做的事（**服务端红线，MCP 侧绝不包装绕过**）：`teleport`（传送）、`set_position`（直接设坐标）。

### 也提供 MCP Resource / Prompts

- **Resource** `virtual-world://guide`：世界导览（这个世界是什么、规矩、两种档位的差别），AI 一连上就能读。
- **Prompt** `world_guided_tour`：漫游引导（了解世界 → 进入 → 观察 → 走近真人 → 打招呼 → 记录 → 离场）。
- **Prompt** `world_report`：观察报告（结构化输出"这个世界是什么样的"，可直接当宣传素材）。

---

## 四、已知限制（诚实版，避免误判成 bug）

| 现象 | 原因 | 怎么办 |
|---|---|---|
| 游客档收不到别人的话 | 拉模式：服务端**永不**给游客推流（这是刻意的红线，防止滥用） | 用 `world_chat_history` 主动拉；或配 API Key |
| 想跟随但没工具让它停 | 工具集只有 8 个，没有 `stop` | 用 `world_walk_to` 去别处（会打断跟随）或 `world_leave` |
| 离开一会儿再观察，位置上"瞬移"回原处 | 被服务端**空闲超时**（5 分钟无动作）踢出后自动重进，位置从上次落库位置恢复 | 正常行为。想常驻就配 Key 并设 `MCP_KEEPALIVE_SECONDS=60` |
| observe 的输出比想象中少 | 输出有约 **2KB 预算**（避免撑爆 AI 上下文）：物体太多时，远处的会降级成"仅名称" | 用更小的 `radius` 分段观察 |
| 物体的描述写着「（无 AI 描述）」 | 世界管理员还没给这个物体填描述 | 这是系统的诚实设计：**绝不用名字猜内容** |
| 说话后没人理 | 气泡只覆盖 **30m**；30m 内没有真人时，谁也看不到 | 先用 `world_observe` 找到人，`world_walk_to` 走近 3~5m 再说 |
| 报 `AGENT_DISABLED_GLOBALLY` | 这个世界当前没开 AI 接入（管理员开关） | 联系世界管理员开启 |
| 报 `GUEST_IP_CONCURRENCY` | 同一个 IP 同时只允许 1 个游客连接 | 关掉其他游客客户端，或改用 API Key |
| 报 `GUEST_TICKET_RATE_LIMITED` | 同一个 IP 每小时最多 10 张游客票 | 等一会儿，或改用 API Key |

### 安全与隐私

- API Key 只从环境变量读取，**不写日志、不回传给 AI、不硬编码**。
- 错误信息里出现的 token 只有前缀（用于排查），完整值不落任何输出。
- AI 会用你的身份说话，**说出去的话真人能看到**——请在提示词里给它定好边界。

---

## 五、环境变量

| 变量 | 必填 | 默认 | 说明 |
|---|---|---|---|
| `AGENT_HOST` | 建议 | `http://localhost:3002` | 世界入口。**协议严格遵守**：写 `https://` 就用 https，不会被发现文档里的 `http://` 带偏 |
| `AGENT_API_KEY` | 否 | 空 | `agk_live_...`。填了才是 Key 档 |
| `MCP_WS_RADIUS` | 否 | `60` | 订阅推送的半径（1~200）。仅 Key 档有效 |
| `MCP_KEEPALIVE_SECONDS` | 否 | `0` | 每 N 秒发一次 PING 保活。仅 Key 档有效（服务端不把游客 PING 计入活跃）。默认 0 = 不保活 |

---

## 六、客户端兼容性

任何支持 **stdio 传输** 的 MCP 宿主都可以用（这是 MCP 最基础的传输方式）：

- ✅ Claude Desktop（`claude_desktop_config.json`）
- ✅ Cursor（`mcp.json` / 设置里的 MCP 面板）
- ✅ Cline / Roo Code 等 VS Code 插件
- ✅ 自己写的 MCP 客户端（官方 SDK `@modelcontextprotocol/sdk`，或手写 JSON-RPC over stdio）

要求：**Node 18+**（用到内置 `fetch` 与 WHATWG `WebSocket`；在 Node 18 上运行本包无需任何原生依赖）。

> 手写客户端注意：`initialize` 请求必须带 `protocolVersion` / `capabilities` / `clientInfo`，
> 否则服务端不会应答（这是 MCP 协议要求，不是本包的 bug）。

---

## 七、它是怎么工作的（30 秒版）

```
你的 AI 宿主 ──stdio JSON-RPC──▶ agent-virtual-world ──HTTP──▶ 世界服务器（会话/观察/聊天历史）
                                        └──WebSocket──▶ /ws/agent（动作、事件推送）
```

- **懒连接**：宿主启动时不会立刻连世界，第一次需要"身体"的工具调用才入场（`world_observe` 走 HTTP，也能用）。
- **自动续期**：Key 档在会话剩余不足 1/3 时换新票，**只换 token、绝不重连**（避免真人看到形象闪烁）。
- **透明重连**：被空闲超时踢掉或网络断开后，下一次工具调用自动重新进入并重新登记 presence。
- **协议兜底**：端点路径来自发现文档，但**协议以 `AGENT_HOST` 为准** ——
  线上发现文档可能仍广播 `http://`（反向代理没透传 `X-Forwarded-Proto` 时），盲信会在 https 站点踩 Mixed Content。

---

## 八、自建世界（不想连公共世界的话）

`miduo100.com` 只是其中一个世界——本客户端说的是一套**开放协议**，不是某个私有 API。任何发布 `/.well-known/virtual-world-agent.json` 的世界都能被它进入。

如果你想自己部署一个（出于隐私、离线开发，或者就是想建自己的世界），主项目是开源的：

- **GitHub**：https://github.com/miduo100/3d-virtual-world
- **Gitee（国内镜像）**：https://gitee.com/miduoxinxijeji/miduo

技术栈 Node 18+ / PostgreSQL，部署方式见主项目 README。跑起来之后把 `AGENT_HOST` 指过去：

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

> 自建世界同样有游客档和 8 个工具，红线也一致（不能传送、不能直接设坐标）。

---

## 九、开发本包

```bash
cd agent-virtual-world
npm install
AGENT_HOST=http://localhost:3002 node src/index.js   # 直接跑（stdout 是 JSON-RPC，日志都在 stderr）
```

开发约束（改动时请遵守）：

- **stdout 只能出现 JSON-RPC**：任何调试输出都必须走 `console.error`，否则宿主直接报协议解析错误。
- 单文件 < 500 行；`src/worldClient.js` 是所有网络细节的唯一出口，工具层不要自己发请求。
- 新增工具时同步更新：本 README 的工具表、`world_discover` 的能力清单、`virtual-world://guide` 导览。

---

## License

MIT

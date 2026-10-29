# Hosted Remote MCP Server Guide (`https://mcp.seowebchecker.com/`) 🤖

How to host and run your own 24/7 public Model Context Protocol (MCP) server at **`https://mcp.seowebchecker.com/`** and connect it to **Smithery.ai**, **Claude Desktop**, and **Cursor**.

Canonical Homepage: [https://seowebchecker.com/](https://seowebchecker.com/)

---

## 🌟 How Hosted Remote MCP Works

Standard MCP servers run locally on a developer's machine using `stdio`. 
A **Hosted Remote MCP Server** runs in the cloud over **Server-Sent Events (SSE)** and HTTP:

```
[Claude / Cursor / Smithery]
         |
         |  GET /sse (Opens real-time event stream)
         v
[https://mcp.seowebchecker.com/sse]
         |
         |  POST /messages?sessionId=... (Sends tool calls)
         v
[SEOWebChecker MCP Engine] ---> Audits target website in real-time
```

No installation is needed by end users — any AI assistant connects directly via URL!

---

## 🚀 3 Ways to Deploy `mcp.seowebchecker.com` (Zero Cost)

### Option 1: Render (Free Web Service — 3 Minutes)
1. Go to [https://render.com/](https://render.com/) and click **New Web Service**.
2. Connect your GitHub repository: `jaiganesh6999/seowebchecker-seoaudit-sdk`.
3. Set the following configuration:
   - **Root Directory**: `mcp`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `node sse-server.js`
4. Under **Custom Domains**, add `mcp.seowebchecker.com`.
5. In your DNS provider (Cloudflare, GoDaddy, Namecheap), add:
   ```text
   CNAME  mcp  <your-app>.onrender.com
   ```

---

### Option 2: Railway or Fly.io (Docker / Node)
1. In Railway or Fly.io, create a new service from GitHub repo `jaiganesh6999/seowebchecker-seoaudit-sdk`.
2. Set start command: `node mcp/sse-server.js`.
3. Add custom domain `mcp.seowebchecker.com`.

---

### Option 3: Smithery.ai Cloud (Zero Hosting Required!)
If you don't want to manage a separate server yourself, **Smithery.ai can host it for you for free**:

1. Go to [https://smithery.ai/](https://smithery.ai/) and click **Submit Server** (log in with GitHub).
2. Enter your repository: `jaiganesh6999/seowebchecker-seoaudit-sdk`.
3. Smithery automatically detects [`smithery.yaml`](../smithery.yaml) and builds a hosted cloud container!
4. Smithery provides a hosted endpoint:
   ```
   https://server.smithery.ai/@jaiganesh6999/seowebchecker/sse
   ```
5. You can use that endpoint directly or proxy it behind `https://mcp.seowebchecker.com/` via Cloudflare Worker.

---

## 📡 Endpoints Provided by `mcp.seowebchecker.com`

| Route | Method | Description |
| :--- | :---: | :--- |
| **`/`** | `GET` | Branded interactive HTML landing page and documentation |
| **`/health`** | `GET` | Server health check and active session count |
| **`/sse`** | `GET` | MCP Server-Sent Events stream for AI clients |
| **`/messages`** | `POST` | JSON-RPC 2.0 tool execution endpoint |

---

## 🤖 How Users Connect to `https://mcp.seowebchecker.com/`

### Claude Desktop (`claude_desktop_config.json`)
```json
{
  "mcpServers": {
    "seowebchecker": {
      "url": "https://mcp.seowebchecker.com/sse"
    }
  }
}
```

### Cursor IDE (`.cursor/mcp.json`)
```json
{
  "mcpServers": {
    "seowebchecker": {
      "url": "https://mcp.seowebchecker.com/sse"
    }
  }
}
```

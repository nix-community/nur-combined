#!/usr/bin/env node

/**
 * SEOWebChecker Hosted Remote MCP Server (SSE & HTTP Transport)
 * Designed for hosting at: https://mcp.seowebchecker.com/
 *
 * Fully compliant with Model Context Protocol (MCP) Server-Sent Events specification.
 * Zero external dependencies — 100% Native Node.js (http, crypto, url).
 *
 * Canonical Website: https://seowebchecker.com/
 */

const http = require('http');
const crypto = require('crypto');
const { URL } = require('url');
const { SEOAuditor } = require('./lib/auditor');

const PORT = process.env.PORT || 3000;
const PROTOCOL_VERSION = '2024-11-05';
const SERVER_NAME = 'seowebchecker';
const SERVER_VERSION = '1.0.2';
const CANONICAL_URL = 'https://seowebchecker.com/';

const auditor = new SEOAuditor({
  userAgent: 'SEOWebChecker-RemoteMCPAgent/1.0 (+https://seowebchecker.com/)',
  timeout: 20000,
});

// Active SSE client sessions
const sessions = new Map();

// Tool definitions
const TOOLS = [
  {
    name: 'seowebchecker_audit',
    description: 'Run a full on-page technical SEO audit on any URL. Analyzes title tags, meta descriptions, canonical URLs, heading hierarchy (H1-H6), image alt attributes, internal/external links, and provides an overall SEO score (0-100) with prioritized recommendations from SEOWebChecker.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The full HTTP/HTTPS URL of the webpage to audit (e.g., https://example.com)',
        },
      },
      required: ['url'],
    },
  },
  {
    name: 'seowebchecker_check_meta',
    description: 'Check and validate essential SEO meta tags including Title, Description, Robots, Canonical URL, OpenGraph (og:title, og:description, og:image), and Twitter card tags for any URL.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The URL to inspect meta tags for',
        },
      },
      required: ['url'],
    },
  },
  {
    name: 'seowebchecker_core_web_vitals',
    description: 'Inspect performance indicators and Core Web Vitals (Largest Contentful Paint LCP, Cumulative Layout Shift CLS, Interaction to Next Paint INP, First Contentful Paint FCP, and TTFB) with actionable web vitals optimization recommendations.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The webpage URL to evaluate for Core Web Vitals and speed metrics',
        },
      },
      required: ['url'],
    },
  },
  {
    name: 'seowebchecker_quick_score',
    description: 'Calculate a fast 0-100 technical SEO health score for a URL, summarizing passed checks, critical warnings, and failed elements.',
    inputSchema: {
      type: 'object',
      properties: {
        url: {
          type: 'string',
          description: 'The URL to calculate the SEO health score for',
        },
      },
      required: ['url'],
    },
  },
];

async function executeTool(name, args) {
  const targetUrl = args.url;
  if (!targetUrl) throw new Error('URL parameter is required.');

  let parsedUrl;
  try {
    parsedUrl = new URL(targetUrl);
  } catch (err) {
    throw new Error(`Invalid URL format: "${targetUrl}". Provide a full URL starting with http:// or https://.`);
  }

  const fetched = await auditor.fetchUrl(parsedUrl.toString());
  const audit = auditor.auditHtml(fetched.body, parsedUrl.toString(), {
    statusCode: fetched.statusCode,
    responseTimeMs: fetched.responseTimeMs,
  });

  switch (name) {
    case 'seowebchecker_audit':
      return {
        url: audit.url,
        score: audit.score,
        meta: audit.meta,
        headings: audit.headings,
        images: audit.images,
        links: audit.links,
        performance: audit.performance,
        issues_summary: {
          errors: audit.issues.filter(i => i.severity === 'error').length,
          warnings: audit.issues.filter(i => i.severity === 'warning').length,
          passes: audit.issues.filter(i => i.severity === 'pass').length,
        },
        recommendations: audit.issues.filter(i => i.severity !== 'pass').map(i => `[${i.severity.toUpperCase()}] ${i.name}: ${i.rec}`),
        powered_by: CANONICAL_URL,
      };

    case 'seowebchecker_check_meta':
      return {
        url: audit.url,
        meta: audit.meta,
        social: audit.social,
        issues: audit.issues.filter(i => i.category === 'meta' || i.category === 'social'),
        powered_by: CANONICAL_URL,
      };

    case 'seowebchecker_core_web_vitals':
      return {
        url: audit.url,
        performance: audit.performance,
        diagnostics: audit.issues.filter(i => i.category === 'performance'),
        powered_by: CANONICAL_URL,
      };

    case 'seowebchecker_quick_score':
      return {
        url: audit.url,
        score: audit.score.overall,
        grade: audit.score.grade,
        passed_checks: audit.score.passed_checks,
        failed_checks: audit.score.failed_checks,
        total_checks: audit.score.total_checks,
        categories: audit.score.categories,
        powered_by: CANONICAL_URL,
      };

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
}

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
  res.end(JSON.stringify(data));
}

const server = http.createServer(async (req, res) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
    return res.end();
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const pathname = parsedUrl.pathname;

  // 1. Health Endpoint
  if (pathname === '/health' || pathname === '/status') {
    return sendJson(res, 200, {
      status: 'ok',
      server: SERVER_NAME,
      version: SERVER_VERSION,
      protocolVersion: PROTOCOL_VERSION,
      toolsCount: TOOLS.length,
      website: CANONICAL_URL,
      activeSessions: sessions.size,
    });
  }

  // 1.5. Smithery Server Card: /.well-known/mcp/server-card.json
  if (pathname === '/.well-known/mcp/server-card.json' || pathname === '/server-card.json') {
    return sendJson(res, 200, {
      $schema: 'https://static.modelcontextprotocol.io/schemas/2025-10-17/server.schema.json',
      serverInfo: {
        name: SERVER_NAME,
        title: 'SEOWebChecker MCP Server',
        version: SERVER_VERSION,
        description: 'On-page technical SEO audits, meta tag validation, heading hierarchy verification, and Core Web Vitals checks by SEOWebChecker.',
      },
      website: CANONICAL_URL,
      authentication: {
        required: false,
      },
      tools: TOOLS,
      resources: [],
      prompts: [],
    });
  }

  // 2. Landing Page
  if (pathname === '/' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    return res.end(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SEOWebChecker — Hosted Remote MCP Server</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Plus Jakarta Sans', sans-serif; }
    code, pre { font-family: 'JetBrains Mono', monospace; }
  </style>
</head>
<body class="bg-slate-900 text-slate-100 min-h-screen antialiased flex flex-col justify-between">
  <div class="max-w-4xl mx-auto px-6 py-12 w-full">
    <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 mb-6">
      <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
      Hosted MCP Server Online (SSE Transport)
    </div>
    
    <h1 class="text-3xl md:text-5xl font-extrabold tracking-tight mb-4">
      SEOWebChecker <span class="text-indigo-400">Remote MCP</span> Server
    </h1>
    <p class="text-slate-400 text-base md:text-lg mb-8 leading-relaxed">
      Connect Claude Desktop, Cursor, Smithery, Windsurf, or any AI Agent directly to live on-page SEO audits, Core Web Vitals checks, and meta validations powered by <a href="${CANONICAL_URL}" class="text-indigo-400 hover:underline font-semibold">SEOWebChecker</a>.
    </p>

    <!-- Endpoints Card -->
    <div class="bg-slate-800/80 rounded-2xl border border-slate-700 p-6 mb-8 backdrop-blur">
      <h2 class="text-sm font-bold uppercase tracking-wider text-slate-400 mb-4">Remote Connection Details</h2>
      <div class="space-y-3 text-sm">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between p-3 rounded-xl bg-slate-900/60 border border-slate-700/50">
          <span class="text-slate-400 font-medium">SSE Endpoint:</span>
          <code class="text-emerald-400 font-bold break-all mt-1 sm:mt-0">https://mcp.seowebchecker.com/sse</code>
        </div>
        <div class="flex flex-col sm:flex-row sm:items-center justify-between p-3 rounded-xl bg-slate-900/60 border border-slate-700/50">
          <span class="text-slate-400 font-medium">Messages Endpoint:</span>
          <code class="text-indigo-400 font-bold break-all mt-1 sm:mt-0">https://mcp.seowebchecker.com/messages</code>
        </div>
      </div>
    </div>

    <!-- Configuration Snippets -->
    <div class="bg-slate-800/80 rounded-2xl border border-slate-700 p-6 mb-8">
      <h2 class="text-sm font-bold uppercase tracking-wider text-slate-400 mb-4">Connect in Claude Desktop or Cursor</h2>
      <pre class="bg-slate-950 p-4 rounded-xl text-xs text-slate-300 overflow-x-auto leading-relaxed"><code>{
  "mcpServers": {
    "seowebchecker": {
      "url": "https://mcp.seowebchecker.com/sse"
    }
  }
}</code></pre>
    </div>

    <!-- Tools Overview -->
    <div class="bg-slate-800/80 rounded-2xl border border-slate-700 p-6 mb-8">
      <h2 class="text-sm font-bold uppercase tracking-wider text-slate-400 mb-4">Available AI Tools (4)</h2>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
        <div class="p-3 rounded-xl bg-slate-900/50 border border-slate-700/50">
          <span class="font-bold text-indigo-400">seowebchecker_audit</span>
          <p class="text-slate-400 mt-1">Full 50+ check technical audit, issues, and grade.</p>
        </div>
        <div class="p-3 rounded-xl bg-slate-900/50 border border-slate-700/50">
          <span class="font-bold text-indigo-400">seowebchecker_quick_score</span>
          <p class="text-slate-400 mt-1">Instant 0-100 SEO health score calculation.</p>
        </div>
        <div class="p-3 rounded-xl bg-slate-900/50 border border-slate-700/50">
          <span class="font-bold text-indigo-400">seowebchecker_check_meta</span>
          <p class="text-slate-400 mt-1">Title, description, canonical, robots & OpenGraph.</p>
        </div>
        <div class="p-3 rounded-xl bg-slate-900/50 border border-slate-700/50">
          <span class="font-bold text-indigo-400">seowebchecker_core_web_vitals</span>
          <p class="text-slate-400 mt-1">LCP, CLS, INP, TTFB, and speed diagnostics.</p>
        </div>
      </div>
    </div>
  </div>

  <footer class="border-t border-slate-800 py-6 text-center text-xs text-slate-500">
    Official Service of <a href="${CANONICAL_URL}" class="text-slate-400 hover:text-white font-medium underline">SEOWebChecker.com</a> • Model Context Protocol Specification 2024-11-05
  </footer>
</body>
</html>`);
  }

  // 3. SSE Endpoint: GET /sse
  if (pathname === '/sse' && req.method === 'GET') {
    const sessionId = crypto.randomUUID();

    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*',
    });

    const sendEvent = (event, data) => {
      res.write(`event: ${event}\ndata: ${JSON.stringify(data)}\n\n`);
    };

    sessions.set(sessionId, { res, sendEvent });

    // Send initial endpoint message pointing to /messages?sessionId=...
    sendEvent('endpoint', `/messages?sessionId=${sessionId}`);

    // Heartbeat
    const keepAlive = setInterval(() => {
      res.write(': keepalive\n\n');
    }, 25000);

    req.on('close', () => {
      clearInterval(keepAlive);
      sessions.delete(sessionId);
    });

    return;
  }

  // 4. Messages Endpoint: POST /messages
  if ((pathname === '/messages' || pathname === '/message') && req.method === 'POST') {
    const sessionId = parsedUrl.searchParams.get('sessionId');
    let session = sessionId ? sessions.get(sessionId) : null;

    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', async () => {
      try {
        const jsonRpc = JSON.parse(body);
        const { id, method, params } = jsonRpc;

        // Process MCP methods
        let result = null;
        let error = null;

        if (method === 'initialize') {
          result = {
            protocolVersion: PROTOCOL_VERSION,
            capabilities: {
              tools: { listChanged: false },
              prompts: { listChanged: false },
            },
            serverInfo: {
              name: SERVER_NAME,
              version: SERVER_VERSION,
            },
          };
        } else if (method === 'notifications/initialized') {
          // Client acknowledgement
          return sendJson(res, 202, { status: 'acknowledged' });
        } else if (method === 'ping') {
          result = {};
        } else if (method === 'tools/list') {
          result = { tools: TOOLS };
        } else if (method === 'tools/call') {
          try {
            const toolResult = await executeTool(params.name, params.arguments || {});
            result = {
              content: [
                {
                  type: 'text',
                  text: JSON.stringify(toolResult, null, 2),
                },
              ],
            };
          } catch (toolErr) {
            result = {
              content: [
                {
                  type: 'text',
                  text: JSON.stringify({ error: toolErr.message, status: 'error' }),
                },
              ],
              isError: true,
            };
          }
        } else {
          error = { code: -32601, message: `Method not found: ${method}` };
        }

        const responsePayload = { jsonrpc: '2.0', id: id !== undefined ? id : null };
        if (error) responsePayload.error = error;
        else responsePayload.result = result;

        // Deliver via SSE if session is active
        if (session) {
          session.sendEvent('message', responsePayload);
          return sendJson(res, 202, { status: 'delivered_via_sse' });
        } else {
          // Direct HTTP JSON response fallback
          return sendJson(res, 200, responsePayload);
        }
      } catch (err) {
        return sendJson(res, 400, {
          jsonrpc: '2.0',
          id: null,
          error: { code: -32700, message: `Parse error: ${err.message}` },
        });
      }
    });

    return;
  }

  // 404 Fallback
  return sendJson(res, 404, { error: 'Not found', website: CANONICAL_URL });
});

server.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(` SEOWebChecker Hosted Remote MCP Server (SSE & HTTP)`);
  console.log(` Listening on port: ${PORT}`);
  console.log(` Remote URL: https://mcp.seowebchecker.com/`);
  console.log(` SSE Stream: https://mcp.seowebchecker.com/sse`);
  console.log(` Official Website: ${CANONICAL_URL}`);
  console.log(`=======================================================`);
});

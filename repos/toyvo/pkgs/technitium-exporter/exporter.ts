#!/usr/bin/env bun
/**
 * Technitium DNS Server Prometheus Exporter
 *
 * Polls the Technitium HTTP API for stats and query logs,
 * then exposes them as Prometheus metrics on :9187.
 *
 * Metrics exposed:
 *   technitium_queries_total           — total queries since start
 *   technitium_queries_per_client      — queries per client IP (last N minutes)
 *   technitium_blocked_total           — total blocked queries
 *   technitium_blocked_per_client      — blocked queries per client IP
 *   technitium_cache_hits_total        — total cache hits
 *   technitium_zones_loaded            — number of zones loaded
 *   technitium_threat_detected_total   — queries matching threat patterns
 */

const TECH_URL = process.env.TECHNITIUM_URL ?? "http://127.0.0.1:5380";
let API_TOKEN = process.env.TECHNITIUM_TOKEN ?? "";
const TOKEN_FILE = process.env.TECHNITIUM_TOKEN_FILE ?? "";
if (!API_TOKEN && TOKEN_FILE) {
  try {
    API_TOKEN = (await Bun.file(TOKEN_FILE).text()).trim();
  } catch {
    // no token available; falls back to admin login below
  }
}

let ADMIN_PASS = "";
const ADMIN_PASS_FILE = process.env.TECHNITIUM_ADMIN_PASS_FILE ?? "";
if (ADMIN_PASS_FILE) {
  try {
    ADMIN_PASS = (await Bun.file(ADMIN_PASS_FILE).text()).trim();
  } catch {
    // no admin password available
  }
}

const REFRESH = Number.parseInt(process.env.TECHNITIUM_REFRESH ?? "30", 10);
if (!Number.isInteger(REFRESH) || REFRESH <= 0) {
  throw new Error(
    `Invalid TECHNITIUM_REFRESH: ${process.env.TECHNITIUM_REFRESH}`,
  );
}

// ---------------------------------------------------------------------------
// Auth helpers
// ---------------------------------------------------------------------------

async function getSessionToken(): Promise<string | null> {
  // Try API_TOKEN first, fall back to admin login.
  if (API_TOKEN) {
    try {
      const res = await fetch(`${TECH_URL}/api/stats`, {
        headers: { Authorization: `Bearer ${API_TOKEN}` },
        signal: AbortSignal.timeout(10_000),
      });
      const data = (await res.json()) as any;
      if (data?.status === "ok") {
        console.error("Using configured API token for auth");
        return API_TOKEN;
      }
    } catch {
      // token request failed; fall through to admin login
    }
    console.error("Configured API token invalid, falling back to admin login");
  }

  if (ADMIN_PASS) {
    try {
      const res = await fetch(`${TECH_URL}/api/user/login`, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: new URLSearchParams({ user: "admin", pass: ADMIN_PASS }),
        signal: AbortSignal.timeout(10_000),
      });
      const data = (await res.json()) as any;
      if (data?.status === "ok" && data?.token) {
        console.error("Admin login successful, using session token");
        return data.token as string;
      }
    } catch {
      // login failed; warned below
    }
  }

  console.error("WARNING: no valid auth method available");
  return null;
}

let sessionToken: string | null = null;

async function activeToken(forceRefresh = false): Promise<string | null> {
  if (sessionToken === null || forceRefresh) {
    sessionToken = await getSessionToken();
  }
  return sessionToken;
}

// ---------------------------------------------------------------------------
// Metric state (gauges keep their last value; counters only increase)
// ---------------------------------------------------------------------------
let queriesTotal = 0;
const queriesPerClient = new Map<string, number>();
let blockedTotal = 0;
const blockedPerClient = new Map<string, number>();
let cacheHits = 0;
let zonesLoaded = 0;
const threatDetected = new Map<string, number>();
function threatKey(client: string, domain: string, indicator: string): string {
  return JSON.stringify([client, domain, indicator]);
}

// Known threat indicators (substrings to watch for)
const THREAT_PATTERNS = [
  "pcaccelerate",
  "speedupmypc",
  "winzipper",
  "acceleratepro",
  "fodcha",
  "botnet",
  "checkip",
  "dga-check",
];

// Quick regex for DGA detection
const DGA_RE = /^[a-z0-9]{10,30}\.(xyz|top|cn|tk|ml|ga|cf|pw|club|info)$/;

/** GET from Technitium API; retry once on auth failure. */
async function apiGet(
  endpoint: string,
  params?: Record<string, string>,
): Promise<any> {
  const qs = params ? `?${new URLSearchParams(params)}` : "";
  const url = `${TECH_URL}${endpoint}${qs}`;
  const doFetch = async (token: string | null) => {
    const headers: Record<string, string> = {};
    if (token) headers["Authorization"] = `Bearer ${token}`;
    const res = await fetch(url, {
      headers,
      signal: AbortSignal.timeout(10_000),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status} on ${endpoint}`);
    return (await res.json()) as any;
  };
  try {
    let data = await doFetch(await activeToken());
    // Detect auth failure and retry with fresh token
    if (
      data?.status === "error" &&
      String(data?.errorMessage ?? "")
        .toLowerCase()
        .includes("token")
    ) {
      const token = await activeToken(true);
      if (token) data = await doFetch(token);
    }
    return data;
  } catch {
    return {};
  }
}

/** Poll /api/stats and update gauges. */
async function updateStats(): Promise<void> {
  const data = await apiGet("/api/stats");
  if (!data || Object.keys(data).length === 0) return;

  const stats = data.stats ?? data; // API may wrap or not wrap
  queriesTotal = stats.totalQueries ?? 0;
  blockedTotal = stats.totalBlocked ?? 0;
  cacheHits = stats.totalCacheHits ?? 0;
  zonesLoaded = stats.zones ?? 0;

  // Per-client breakdown (if available in the response)
  for (const [ip, count] of Object.entries(
    (stats.clientQueries ?? {}) as Record<string, number>,
  )) {
    queriesPerClient.set(ip, count);
  }
  for (const [ip, count] of Object.entries(
    (stats.clientBlocked ?? {}) as Record<string, number>,
  )) {
    blockedPerClient.set(ip, count);
  }
}

/** Poll recent query logs and count threat matches. */
async function checkThreats(): Promise<void> {
  const data = await apiGet("/api/logs", {
    type: "Query",
    page: "1",
    limit: "500",
  });
  if (!data || Object.keys(data).length === 0) return;

  for (const entry of (data.logs ?? []) as Array<{
    query?: string;
    client?: string;
  }>) {
    const domain = entry.query ?? "";
    const client = entry.client ?? "unknown";

    // Check known bad substrings
    for (const pat of THREAT_PATTERNS) {
      if (domain.toLowerCase().includes(pat)) {
        const key = threatKey(client, domain, pat);
        threatDetected.set(key, (threatDetected.get(key) ?? 0) + 1);
      }
    }

    // DGA heuristic
    if (DGA_RE.test(domain.toLowerCase())) {
      const key = threatKey(client, domain, "dga_heuristic");
      threatDetected.set(key, (threatDetected.get(key) ?? 0) + 1);
    }
  }
}

async function pollOnce(): Promise<void> {
  try {
    await updateStats();
    await checkThreats();
  } catch (e) {
    console.error(`poll failed: ${e}`);
  }
}

/** Escape a Prometheus label value. */
function escLabel(v: string): string {
  return v.replace(/\\/g, "\\\\").replace(/\n/g, "\\n").replace(/"/g, '\\"');
}

function renderMetrics(): string {
  const lines = [
    "# HELP technitium_queries_total Total DNS queries handled",
    "# TYPE technitium_queries_total gauge",
    `technitium_queries_total ${queriesTotal}`,
    "# HELP technitium_queries_per_client Queries per client IP",
    "# TYPE technitium_queries_per_client gauge",
  ];
  for (const [client, count] of queriesPerClient) {
    lines.push(
      `technitium_queries_per_client{client="${escLabel(client)}"} ${count}`,
    );
  }
  lines.push(
    "# HELP technitium_blocked_total Total blocked queries",
    "# TYPE technitium_blocked_total gauge",
    `technitium_blocked_total ${blockedTotal}`,
    "# HELP technitium_blocked_per_client Blocked queries per client IP",
    "# TYPE technitium_blocked_per_client gauge",
  );
  for (const [client, count] of blockedPerClient) {
    lines.push(
      `technitium_blocked_per_client{client="${escLabel(client)}"} ${count}`,
    );
  }
  lines.push(
    "# HELP technitium_cache_hits_total Total cache hits",
    "# TYPE technitium_cache_hits_total gauge",
    `technitium_cache_hits_total ${cacheHits}`,
    "# HELP technitium_zones_loaded Number of zones currently loaded",
    "# TYPE technitium_zones_loaded gauge",
    `technitium_zones_loaded ${zonesLoaded}`,
    "# HELP technitium_threat_detected_total Queries matching threat indicators",
    "# TYPE technitium_threat_detected_total counter",
  );
  for (const [key, count] of threatDetected) {
    const [client, domain, indicator] = JSON.parse(key) as [
      string,
      string,
      string,
    ];
    lines.push(
      `technitium_threat_detected_total{client="${escLabel(client)}",domain="${escLabel(domain)}",indicator="${escLabel(indicator)}"} ${count}`,
    );
  }
  return lines.join("\n") + "\n";
}

async function main(): Promise<void> {
  const port = Number.parseInt(process.env.EXPORTER_PORT ?? "9187", 10);
  const addr = process.env.EXPORTER_ADDR ?? "127.0.0.1";

  await pollOnce();
  setInterval(() => {
    void pollOnce();
  }, REFRESH * 1000);

  Bun.serve({
    hostname: addr,
    port,
    fetch(req) {
      const path = new URL(req.url).pathname;
      if (path === "/metrics") {
        return new Response(renderMetrics(), {
          headers: {
            "Content-Type": "text/plain; version=0.0.4; charset=utf-8",
          },
        });
      }
      if (path === "/health") {
        return new Response("ok\n", {
          headers: { "Content-Type": "text/plain" },
        });
      }
      return new Response(null, { status: 404 });
    },
  });
  console.error(
    `technitium-exporter listening on http://${addr}:${port}/metrics`,
  );
}

if (import.meta.main) {
  await main();
}

#!/usr/bin/env bun
/**
 * Network Device Inventory Collector
 *
 * Collects device data from:
 *   • Linux ARP table  (ip neigh show)
 *   • Kea DHCP4 leases  (/var/lib/kea/dhcp4.leases)
 *   • Technitium DNS client stats (optional, via API)
 *
 * Writes Prometheus textfile metrics to the given output path.
 *
 * Metrics written:
 *   network_device_info{ip="...",mac="...",hostname="...",vendor="...",source="..."} 1
 *   network_device_last_seen_timestamp{ip="..."} <unix_ts>
 *   network_device_count   <gauge>
 */

interface Device {
  ip: string;
  mac: string;
  hostname: string;
  vendor: string;
  source: string;
  state: string;
}

const OUTPUT =
  process.env.INVENTORY_OUTPUT ??
  "/var/lib/alloy/textfiles/network_inventory.prom";
const KEA_LEASES = process.env.KEA_LEASES ?? "/var/lib/kea/dhcp4.leases";
const TECH_URL = process.env.TECHNITIUM_URL ?? "";
let API_TOKEN = process.env.TECHNITIUM_API_TOKEN ?? "";
const TOKEN_FILE = process.env.TECHNITIUM_TOKEN_FILE ?? "";
if (!API_TOKEN && TOKEN_FILE) {
  try {
    API_TOKEN = (await Bun.file(TOKEN_FILE).text()).trim();
  } catch {
    // no token available; Technitium polling is skipped below
  }
}

// ---------------------------------------------------------------------------
// OUI lookup helpers (simple vendor fingerprinting from MAC prefix)
// ---------------------------------------------------------------------------
const OUI_HINTS: Record<string, string> = {
  "70:85:c2": "Realtek / MSI",
  "4c:20:b8": "Apple",
  "d4:be:dc": "Amazon",
  "d0:12:55": "Samsung",
  "1c:1e:e3": "Espressif / IoT",
  "7c:2b:e1": "Intel",
  "10:27:f5": "TP-Link",
  "30:9c:23": "Realtek",
  "00:e0:67": "Protectli",
  "e4:5f:01": "Raspberry Pi",
  "dc:a6:32": "Raspberry Pi",
  "68:fe:f7": "Intel",
  "b4:6b:fc": "Intel",
  "b4:8c:9d": "Valve / Steam",
  "be:7f:95": "Apple (randomized)",
  "7a:22:0c": "Google (randomized)",
  "3e:ef:ce": "Apple (randomized)",
  "b2:88:66": "Apple (randomized)",
  "8c:fd:f0": "Intel",
};

function vendorFromMac(mac: string): string {
  return OUI_HINTS[mac.slice(0, 8).toLowerCase()] ?? "Unknown";
}

async function parseArp(): Promise<Device[]> {
  const devices: Device[] = [];
  let out: string;
  try {
    const proc = Bun.spawn(["ip", "neigh", "show"], {
      stdout: "pipe",
      stderr: "ignore",
      timeout: 10_000,
    });
    out = await new Response(proc.stdout).text();
    await proc.exited;
  } catch {
    return devices;
  }

  for (const line of out.split("\n")) {
    // e.g.  "10.1.0.100 dev eno1 lladdr d4:be:dc:5d:84:99 REACHABLE"
    const m =
      /^(\d+\.\d+\.\d+\.\d+)\s+dev\s+\S+\s+lladdr\s+([0-9a-fA-F:]+)\s+(\S+)/.exec(
        line,
      );
    if (!m) continue;
    const [, ip, mac, state] = m;
    devices.push({
      ip,
      mac: mac.toLowerCase(),
      hostname: "",
      vendor: vendorFromMac(mac),
      source: "arp",
      state,
    });
  }
  return devices;
}

/** Split one CSV row, honoring double-quoted fields. */
function splitCsvRow(row: string): string[] {
  const fields: string[] = [];
  let cur = "";
  let inQuotes = false;
  for (let i = 0; i < row.length; i++) {
    const c = row[i];
    if (inQuotes) {
      if (c === '"') {
        if (row[i + 1] === '"') {
          cur += '"';
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cur += c;
      }
    } else if (c === '"') {
      inQuotes = true;
    } else if (c === ",") {
      fields.push(cur);
      cur = "";
    } else {
      cur += c;
    }
  }
  fields.push(cur);
  return fields;
}

async function parseKea(): Promise<Device[]> {
  const devices: Device[] = [];
  const file = Bun.file(KEA_LEASES);
  if (!(await file.exists())) return devices;

  try {
    const lines = (await file.text()).split("\n").filter((l) => l !== "");
    if (lines.length === 0) return devices;
    const header = splitCsvRow(lines[0]);
    const ipIdx = header.indexOf("address");
    const macIdx = header.indexOf("hwaddr");
    const hostnameIdx = header.indexOf("hostname");
    if (ipIdx === -1) return devices;
    for (const line of lines.slice(1)) {
      const row = splitCsvRow(line);
      const ip = (row[ipIdx] ?? "").trim();
      if (!ip) continue;
      const mac = (row[macIdx] ?? "").trim().toLowerCase();
      const hostname =
        hostnameIdx === -1 ? "" : (row[hostnameIdx] ?? "").trim();
      devices.push({
        ip,
        mac,
        hostname,
        vendor: vendorFromMac(mac),
        source: "kea",
        state: "leased",
      });
    }
  } catch {
    // unreadable lease file; treat as no leases
  }
  return devices;
}

async function parseTechnitium(): Promise<Device[]> {
  const devices: Device[] = [];
  if (!TECH_URL) return devices;

  try {
    const headers: Record<string, string> = {};
    if (API_TOKEN) headers["Authorization"] = `Bearer ${API_TOKEN}`;
    const res = await fetch(`${TECH_URL}/api/stats`, {
      headers,
      signal: AbortSignal.timeout(10_000),
    });
    if (!res.ok) return devices;
    const data = (await res.json()) as any;
    const clients: Record<string, unknown> = data?.stats?.clientQueries ?? {};
    for (const ip of Object.keys(clients)) {
      devices.push({
        ip,
        mac: "",
        hostname: "",
        vendor: "",
        source: "technitium",
        state: "active",
      });
    }
  } catch {
    // Technitium unreachable; skip it
  }
  return devices;
}

function mergeDevices(deviceLists: Device[][]): Record<string, Device> {
  // Merge multiple device lists, keyed by IP, keeping the richest record.
  const merged: Record<string, Device> = {};
  for (const devList of deviceLists) {
    for (const dev of devList) {
      const existing = merged[dev.ip];
      if (!existing) {
        merged[dev.ip] = dev;
        continue;
      }
      // Keep non-empty fields from any source
      for (const key of ["mac", "hostname", "vendor"] as const) {
        if (dev[key] && !existing[key]) existing[key] = dev[key];
      }
      // Prefer kea/arp source labels over technitium when available
      if (dev.source === "kea" || dev.source === "arp") {
        existing.source = dev.source;
      }
      existing.state = dev.state || existing.state;
    }
  }
  return merged;
}

/** Escape a Prometheus label value. */
function escLabel(v: string): string {
  return v.replace(/\\/g, "\\\\").replace(/\n/g, "\\n").replace(/"/g, '\\"');
}

async function writeMetrics(devices: Record<string, Device>): Promise<void> {
  const now = Date.now() / 1000;
  const lines: string[] = [
    "# HELP network_device_info Known network device",
    "# TYPE network_device_info gauge",
  ];
  for (const [ip, dev] of Object.entries(devices)) {
    lines.push(
      `network_device_info{ip="${escLabel(ip)}",mac="${escLabel(dev.mac)}",hostname="${escLabel(dev.hostname)}",vendor="${escLabel(dev.vendor)}",source="${escLabel(dev.source)}"} 1`,
    );
  }
  lines.push(
    "# HELP network_device_last_seen_timestamp Unix timestamp of last inventory collection",
    "# TYPE network_device_last_seen_timestamp gauge",
  );
  for (const ip of Object.keys(devices)) {
    lines.push(
      `network_device_last_seen_timestamp{ip="${escLabel(ip)}"} ${now}`,
    );
  }
  lines.push(
    "# HELP network_device_count Total known devices",
    "# TYPE network_device_count gauge",
    `network_device_count ${Object.keys(devices).length}`,
  );
  // Bun.write creates parent directories automatically
  await Bun.write(OUTPUT, lines.join("\n") + "\n");
}

async function main(): Promise<void> {
  const arp = await parseArp();
  const kea = await parseKea();
  const tech = await parseTechnitium();

  const merged = mergeDevices([arp, kea, tech]);
  await writeMetrics(merged);

  console.error(
    `Inventory: ${Object.keys(merged).length} devices written to ${OUTPUT}`,
  );
}

if (import.meta.main) {
  await main();
}

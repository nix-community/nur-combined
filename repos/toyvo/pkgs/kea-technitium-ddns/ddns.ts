#!/usr/bin/env bun
/**
 * Kea DHCP → Technitium dynamic DNS sync (one-shot).
 *
 * Reads the Kea DHCPv4 lease file, builds the desired set of
 * `<hostname>.<zone>` A records, and reconciles them with the
 * Technitium zone via its HTTP API.
 *
 * Safety rules (see spec):
 *   - Only subnets in ALLOWED_SUBNETS are published.
 *   - Names in STATIC_NAMES_FILE are never touched.
 *   - Only TTL-120 records are managed; all other records are ignored.
 *   - If the lease file or the existing-records list cannot be read,
 *     the script aborts BEFORE mutating anything.
 *
 * Required environment:
 *   TECHNITIUM_URL               (default http://127.0.0.1:5380)
 *   TECHNITIUM_TOKEN_FILE        API token (preferred auth)
 *   TECHNITIUM_ADMIN_PASS_FILE   admin password (fallback auth)
 *   TECHNITIUM_ADMIN_USER        (default "admin")
 *   KEA_LEASES                   (default /var/lib/kea/dhcp4.leases)
 *   DNS_ZONE                     (default "home.arpa")
 *   ALLOWED_SUBNETS              (default "1", comma separated)
 *   STATIC_NAMES_FILE            JSON array of reserved hostnames
 */

import {
  buildDesiredRecords,
  diffRecords,
  isSnapshotTrustworthy,
  parseKeaLeases,
  type ExistingRecord,
} from "./sync";

const DYNAMIC_TTL = 120;

const url = process.env.TECHNITIUM_URL ?? "http://127.0.0.1:5380";
const tokenFile = process.env.TECHNITIUM_TOKEN_FILE ?? "";
const adminUser = process.env.TECHNITIUM_ADMIN_USER ?? "admin";
const adminPassFile = process.env.TECHNITIUM_ADMIN_PASS_FILE ?? "";
const leasesFile = process.env.KEA_LEASES ?? "/var/lib/kea/dhcp4.leases";
const zone = process.env.DNS_ZONE ?? "home.arpa";
const allowedSubnets = (process.env.ALLOWED_SUBNETS ?? "1")
  .split(",")
  .map((s) => Number.parseInt(s.trim(), 10))
  .filter((n) => Number.isInteger(n));
const staticNamesFile = process.env.STATIC_NAMES_FILE ?? "";

async function readFile(path: string): Promise<string> {
  return (await Bun.file(path).text()).trim();
}

/** Make an API request. Returns parsed JSON or null on failure. */
async function request(
  ep: string,
  data?: Record<string, string>,
  method = "GET",
  authToken?: string,
): Promise<any> {
  const headers: Record<string, string> = {};
  if (authToken) headers["Authorization"] = "Bearer " + authToken;
  const init: RequestInit = {
    headers,
    signal: AbortSignal.timeout(30_000),
  };
  if (data) {
    headers["Content-Type"] = "application/x-www-form-urlencoded";
    init.method = method;
    init.body = new URLSearchParams(data).toString();
  } else {
    init.method = method;
  }
  try {
    const res = await fetch(url + ep, init);
    if (!res.ok) throw new Error(`HTTP ${res.status} ${res.statusText}`);
    return await res.json();
  } catch (e) {
    console.error(`  HTTP error on ${ep}: ${e}`);
    return null;
  }
}

/** True if response is an object with status == 'ok'. */
function isOk(resp: unknown): boolean {
  return (
    typeof resp === "object" &&
    resp !== null &&
    (resp as Record<string, unknown>).status === "ok"
  );
}

async function getAuthToken(): Promise<string | null> {
  const token = tokenFile ? await readFile(tokenFile).catch(() => "") : "";
  if (token) {
    const resp = await request("/api/stats", undefined, "GET", token);
    if (isOk(resp)) return token;
    console.error("Token rejected, falling back to admin login.");
  }
  const adminPass = adminPassFile
    ? await readFile(adminPassFile).catch(() => "")
    : "";
  const login = await request(
    "/api/user/login",
    { user: adminUser, pass: adminPass || "admin" },
    "POST",
  );
  if (isOk(login) && (login as any)?.token) return (login as any).token;
  return null;
}

interface ZoneRecord {
  name?: string;
  type?: string;
  ttl?: number;
  rData?: { ipAddress?: string };
}

/** List existing A records in the zone as short-name ExistingRecords. */
async function listExisting(t: string): Promise<ExistingRecord[] | null> {
  const r = await request(
    `/api/zones/records/get?domain=${encodeURIComponent(zone)}&zone=${encodeURIComponent(zone)}&listZone=true`,
    undefined,
    "GET",
    t,
  );
  if (!isOk(r)) {
    console.error(`Failed to list zone records: ${JSON.stringify(r)}`);
    return null;
  }
  const records: ZoneRecord[] = (r as any)?.response?.records ?? [];
  const out: ExistingRecord[] = [];
  const suffix = `.${zone.toLowerCase()}`;
  for (const rec of records) {
    if ((rec.type ?? "").toUpperCase() !== "A") continue;
    const fqdn = (rec.name ?? "").toLowerCase();
    if (!fqdn || fqdn === zone.toLowerCase()) continue; // skip apex
    if (!fqdn.endsWith(suffix)) continue;
    const short = fqdn.slice(0, -suffix.length);
    if (!short || short.includes(".")) continue;
    const ip = rec.rData?.ipAddress ?? "";
    if (!ip) continue;
    out.push({ name: short, ip, ttl: rec.ttl ?? 0 });
  }
  return out;
}

async function ensureZone(t: string): Promise<void> {
  const r = await request(
    "/api/zones/create",
    { zone, type: "Primary" },
    "POST",
    t,
  );
  if (isOk(r)) {
    console.error(`Zone ${zone} created.`);
    return;
  }
  const msg = String((r as any)?.errorMessage ?? "").toLowerCase();
  if (msg.includes("already exists")) return;
  console.error(`Warning: zone create failed: ${JSON.stringify(r)}`);
}

async function main(): Promise<void> {
  // 1. Static (reserved) names — never touched.
  let staticNames = new Set<string>();
  if (staticNamesFile) {
    try {
      const names = (await Bun.file(staticNamesFile).json()) as string[];
      staticNames = new Set(names.map((n) => String(n).toLowerCase()));
    } catch (e) {
      console.error(`FATAL: cannot read static names: ${e}`);
      process.exit(1);
    }
  }

  // 2. Kea leases — abort before any mutation if unreadable.
  let csv: string;
  try {
    csv = await Bun.file(leasesFile).text();
  } catch (e) {
    console.error(`FATAL: cannot read Kea leases: ${e}`);
    process.exit(1);
  }
  const leases = parseKeaLeases(csv, allowedSubnets, Date.now() / 1000);
  const desired = buildDesiredRecords(leases, staticNames);
  console.error(
    `Leases: ${leases.length} valid, desired DNS records: ${desired.size}`,
  );

  // 3. Auth.
  const t = await getAuthToken();
  if (!t) {
    console.error("FATAL: Could not authenticate with Technitium API.");
    process.exit(1);
  }

  await ensureZone(t);

  // 4. Reconcile — abort before any mutation if the list fails.
  const existing = await listExisting(t);
  if (!existing) {
    console.error("FATAL: cannot list existing zone records, aborting.");
    process.exit(1);
  }
  const byName = new Map(existing.map((r) => [r.name, r]));
  const dataRows = Math.max(
    0,
    csv.split("\n").filter((l) => l !== "").length - 1,
  );
  const dynamicCount = existing.filter((r) => r.ttl === DYNAMIC_TTL).length;
  if (!isSnapshotTrustworthy(dataRows, dynamicCount)) {
    console.error(
      "FATAL: lease snapshot is empty but dynamic records exist; aborting to avoid mass delete.",
    );
    process.exit(1);
  }
  const { toAdd, toUpdate, toDelete } = diffRecords(desired, existing);

  for (const { name, ip } of toAdd) {
    const domain = `${name}.${zone}`;
    const r = await request(
      "/api/zones/records/add",
      {
        domain,
        zone,
        type: "A",
        ttl: String(DYNAMIC_TTL),
        ipAddress: ip,
      },
      "POST",
      t,
    );
    console.error(
      isOk(r)
        ? `ADD ${domain} -> ${ip}`
        : `ADD FAILED ${domain}: ${JSON.stringify(r)}`,
    );
  }
  for (const { name, ip } of toUpdate) {
    const domain = `${name}.${zone}`;
    const oldIp = byName.get(name)?.ip ?? "";
    const r = await request(
      "/api/zones/records/update",
      {
        domain,
        zone,
        type: "A",
        ttl: String(DYNAMIC_TTL),
        ipAddress: oldIp,
        newIpAddress: ip,
      },
      "POST",
      t,
    );
    console.error(
      isOk(r)
        ? `UPDATE ${domain} ${oldIp} -> ${ip}`
        : `UPDATE FAILED ${domain}: ${JSON.stringify(r)}`,
    );
  }
  for (const { name } of toDelete) {
    const domain = `${name}.${zone}`;
    const oldIp = byName.get(name)?.ip ?? "";
    const r = await request(
      "/api/zones/records/delete",
      { domain, zone, type: "A", ipAddress: oldIp },
      "POST",
      t,
    );
    console.error(
      isOk(r)
        ? `DELETE ${domain} (was ${oldIp})`
        : `DELETE FAILED ${domain}: ${JSON.stringify(r)}`,
    );
  }
  console.error(
    `Done: ${toAdd.length} added, ${toUpdate.length} updated, ${toDelete.length} deleted.`,
  );
}

if (import.meta.main) {
  await main();
}

/**
 * Pure Kea-lease → desired-DNS-records logic.
 *
 * No network, no env: parsing, sanitizing, and diffing only.
 * The Technitium API sync lives in ddns.ts and consumes these functions.
 */

export interface ParsedLease {
  ip: string;
  hostname: string;
  subnetId: number;
}

export interface ExistingRecord {
  name: string;
  ip: string;
  ttl: number;
}

/** Hostname without domain → IP for records we want to exist. */
export type DesiredRecords = Map<string, string>;

/** Lowercase, replace underscores/whitespace with `-`, validate RFC 1035 label. */
export function sanitizeHostname(raw: string): string | null {
  const lowered = raw
    .trim()
    .toLowerCase()
    .replace(/[_\s]+/g, "-");
  if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(lowered)) return null;
  return lowered;
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

/**
 * Parse a Kea memfile DHCPv4 CSV lease dump.
 * Keeps only leases on allowed subnets that have not expired and carry a
 * usable hostname. Unparseable `expire` values are treated as expired.
 */
export function parseKeaLeases(
  csv: string,
  allowedSubnetIds: number[],
  nowSec: number,
): ParsedLease[] {
  const allowed = new Set(allowedSubnetIds);
  const lines = csv.split("\n").filter((l) => l !== "");
  if (lines.length === 0) return [];
  const header = splitCsvRow(lines[0]);
  const ipIdx = header.indexOf("address");
  const hostnameIdx = header.indexOf("hostname");
  const expireIdx = header.indexOf("expire");
  const subnetIdx =
    header.indexOf("subnet_id") !== -1
      ? header.indexOf("subnet_id")
      : header.indexOf("subnet-id") !== -1
        ? header.indexOf("subnet-id")
        : header.indexOf("subnet");
  if (ipIdx === -1 || hostnameIdx === -1) return [];

  const out: ParsedLease[] = [];
  for (const line of lines.slice(1)) {
    const row = splitCsvRow(line);
    const ip = (row[ipIdx] ?? "").trim();
    if (!ip) continue;
    if (subnetIdx !== -1) {
      const subnetId = Number.parseInt((row[subnetIdx] ?? "").trim(), 10);
      if (!allowed.has(subnetId)) continue;
    } else if (allowed.size > 0) {
      continue;
    }
    if (expireIdx !== -1) {
      const expire = Number.parseInt((row[expireIdx] ?? "").trim(), 10);
      if (!Number.isInteger(expire) || expire <= nowSec) continue;
    }
    const hostname = sanitizeHostname((row[hostnameIdx] ?? "").trim());
    if (!hostname) continue;
    const subnetId =
      subnetIdx !== -1 ? Number.parseInt((row[subnetIdx] ?? "").trim(), 10) : 0;
    out.push({ ip, hostname, subnetId });
  }
  return out;
}

/**
 * Build the desired hostname → IP map.
 * Skips static names (case-insensitive) and unusable hostnames;
 * duplicate hostnames resolve last-wins so repeated syncs converge.
 */
export function buildDesiredRecords(
  leases: Array<{ ip: string; hostname: string }>,
  staticNames: Set<string>,
): DesiredRecords {
  const lower = new Set([...staticNames].map((n) => n.toLowerCase()));
  const desired: DesiredRecords = new Map();
  for (const lease of leases) {
    const name = sanitizeHostname(lease.hostname);
    if (!name || lower.has(name)) continue;
    desired.set(name, lease.ip);
  }
  return desired;
}

export interface RecordDiff {
  toAdd: Array<{ name: string; ip: string }>;
  toUpdate: Array<{ name: string; ip: string }>;
  toDelete: Array<{ name: string }>;
}

/**
 * A header-only/empty lease snapshot alongside existing dynamic records
 * means Kea was likely mid-rewrite: abort instead of deleting everything.
 */
export function isSnapshotTrustworthy(
  dataRowCount: number,
  existingDynamicCount: number,
): boolean {
  return dataRowCount > 0 || existingDynamicCount === 0;
}

/**
 * Diff desired state against existing zone records.
 * Records with a TTL other than 120 are treated as static/managed
 * elsewhere and are never added over, updated, or deleted.
 */
export function diffRecords(
  desired: DesiredRecords,
  existing: ExistingRecord[],
): RecordDiff {
  const DYNAMIC_TTL = 120;
  const byName = new Map(existing.map((r) => [r.name, r]));
  const toAdd: RecordDiff["toAdd"] = [];
  const toUpdate: RecordDiff["toUpdate"] = [];
  const toDelete: RecordDiff["toDelete"] = [];

  for (const [name, ip] of desired) {
    const cur = byName.get(name);
    if (!cur) {
      toAdd.push({ name, ip });
    } else if (cur.ttl !== DYNAMIC_TTL) {
      if (cur.ip === ip) continue;
      // A static record owns this name: leave it alone.
      continue;
    } else if (cur.ip !== ip) {
      toUpdate.push({ name, ip });
    }
  }
  for (const rec of existing) {
    if (rec.ttl !== DYNAMIC_TTL) continue;
    if (!desired.has(rec.name)) toDelete.push({ name: rec.name });
  }
  return { toAdd, toUpdate, toDelete };
}

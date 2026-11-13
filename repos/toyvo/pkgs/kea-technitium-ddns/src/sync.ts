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

/**
 * Lowercase, strip one trailing dot (FQDN notation), replace
 * underscores/whitespace with `-`, validate RFC 1035 label.
 */
export function sanitizeHostname(raw: string): string | null {
  const lowered = raw
    .trim()
    .toLowerCase()
    .replace(/\.$/, "")
    .replace(/[_\s]+/g, "-");
  if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(lowered)) return null;
  return lowered;
}

/**
 * Normalize a `lease4-get-all` response into parsed leases.
 *
 * Kea reports `cltt` (client last transaction time, epoch seconds) and
 * `valid-lft`; a lease is live while `cltt + valid-lft` is in the future.
 * Keeps only leases on allowed subnets that have not expired, carry a
 * usable hostname, and are in assigned state. Missing or unparseable
 * times are treated as expired (fail-closed).
 */
export function normalizeControlLeases(
  raw: unknown[],
  allowedSubnetIds: number[],
  nowSec: number,
): ParsedLease[] {
  const allowed = new Set(allowedSubnetIds);
  const out: ParsedLease[] = [];
  for (const item of raw) {
    if (typeof item !== "object" || item === null) continue;
    const rec = item as Record<string, unknown>;
    const ip = typeof rec["ip-address"] === "string" ? rec["ip-address"] : "";
    if (!ip) continue;
    const subnetId =
      typeof rec["subnet-id"] === "number" ? rec["subnet-id"] : NaN;
    if (!allowed.has(subnetId)) continue;
    const state = rec["state"];
    if (state !== undefined && state !== 0) continue;
    const cltt = typeof rec["cltt"] === "number" ? rec["cltt"] : NaN;
    const validLft =
      typeof rec["valid-lft"] === "number"
        ? rec["valid-lft"]
        : typeof rec["valid-lifetime"] === "number"
          ? rec["valid-lifetime"]
          : NaN;
    if (!Number.isInteger(cltt) || !Number.isInteger(validLft)) continue;
    if (cltt + validLft <= nowSec) continue;
    const hostname =
      typeof rec["hostname"] === "string"
        ? sanitizeHostname(rec["hostname"].trim())
        : null;
    if (!hostname) continue;
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

export interface SeenEntry {
  ip: string;
  lastSeen: number;
}
export type SeenState = Record<string, SeenEntry>;

export interface SyncPlan {
  toAdd: Array<{ name: string; ip: string }>;
  toUpdate: Array<{ name: string; ip: string }>;
  toDelete: Array<{ name: string }>;
  next: SeenState;
}

/**
 * Immediate adds/updates, grace-delayed deletes.
 *
 * Desired entries refresh their lastSeen clock every run. A dynamic
 * record absent from the leases is deleted only after being continuously
 * absent for graceSec (covers torn lease-file reads, sleep, brief
 * roaming). First sighting of an absence starts the clock. State entries
 * for names in neither desired nor the zone are pruned.
 */
export function planSync(
  desired: DesiredRecords,
  existing: ExistingRecord[],
  prev: SeenState,
  nowSec: number,
  graceSec: number,
): SyncPlan {
  const {
    toAdd,
    toUpdate,
    toDelete: immediate,
  } = diffRecords(desired, existing);
  const byName = new Map(existing.map((r) => [r.name, r]));
  const next: SeenState = {};
  for (const [name, ip] of desired) next[name] = { ip, lastSeen: nowSec };
  const toDelete: SyncPlan["toDelete"] = [];
  for (const { name } of immediate) {
    const seen = prev[name];
    if (!seen) {
      // Absence noticed for the first time: start the clock, keep it.
      next[name] = { ip: byName.get(name)?.ip ?? "", lastSeen: nowSec };
      continue;
    }
    if (nowSec - seen.lastSeen < graceSec) {
      next[name] = seen;
      continue;
    }
    // Grace expired: delete (and drop from state by omitting).
    toDelete.push({ name });
  }
  return { toAdd, toUpdate, toDelete, next };
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

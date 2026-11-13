import { expect, test } from "bun:test";
import {
  sanitizeHostname,
  normalizeControlLeases,
  buildDesiredRecords,
  diffRecords,
  isSnapshotTrustworthy,
  planSync,
} from "./src/sync";
test("sanitize lowercases and rejects junk", () => {
  expect(sanitizeHostname("My_Laptop ")).toBe("my-laptop");
  expect(sanitizeHostname("")).toBeNull();
  expect(sanitizeHostname("***")).toBeNull();
  expect(sanitizeHostname("-bad-")).toBeNull();
  expect(sanitizeHostname("windows-desktop.")).toBe("windows-desktop");
  expect(sanitizeHostname(".")).toBeNull();
});
test("normalizeControlLeases maps fields and filters", () => {
  const lease = (over: Record<string, unknown>) => ({
    "ip-address": "10.1.0.70",
    "hw-address": "aa:bb:cc:dd:ee:ff",
    hostname: "Laptop1",
    "subnet-id": 1,
    cltt: 1800000000,
    "valid-lft": 32400,
    state: 0,
    ...over,
  });
  expect(
    normalizeControlLeases(
      [
        lease({}),
        lease({ "ip-address": "10.1.0.71", hostname: "old", cltt: 1000000000 }),
        lease({
          "ip-address": "10.1.20.90",
          hostname: "guest",
          "subnet-id": 20,
        }),
        lease({ "ip-address": "10.1.0.72", hostname: "" }),
        lease({ "ip-address": "10.1.0.73", hostname: "declined", state: 1 }),
        lease({
          "ip-address": "10.1.0.74",
          hostname: "nodata",
          cltt: undefined,
        }),
      ],
      [1],
      1800000000,
    ),
  ).toEqual([{ ip: "10.1.0.70", hostname: "laptop1", subnetId: 1 }]);
});
test("buildDesired skips static names and last-wins duplicates", () => {
  const m = buildDesiredRecords(
    [
      { ip: "10.1.0.70", hostname: "Laptop1" },
      { ip: "10.1.0.71", hostname: "laptop1" },
      { ip: "10.1.0.72", hostname: "NAS" },
    ],
    new Set(["nas", "router"]),
  );
  expect(m.get("laptop1")).toBe("10.1.0.71");
  expect(m.has("nas")).toBe(false);
});
test("diff only deletes TTL-120 records missing from desired", () => {
  const d = diffRecords(new Map([["laptop1", "10.1.0.70"]]), [
    { name: "laptop1", ip: "10.1.0.70", ttl: 120 },
    { name: "stale", ip: "10.1.0.99", ttl: 120 },
    { name: "router", ip: "10.1.0.1", ttl: 300 },
  ]);
  expect(d.toDelete).toEqual([{ name: "stale" }]);
  expect(d.toAdd).toEqual([]);
});
test("empty snapshot with existing dynamic records is untrustworthy", () => {
  expect(isSnapshotTrustworthy(0, 3)).toBe(false);
  expect(isSnapshotTrustworthy(0, 0)).toBe(true);
  expect(isSnapshotTrustworthy(5, 3)).toBe(true);
});
test("planSync adds immediately but delays deletes until grace expires", () => {
  const existing = [
    { name: "gone", ip: "10.1.0.9", ttl: 120 },
    { name: "staying", ip: "10.1.0.7", ttl: 120 },
  ];
  const desired = new Map([
    ["staying", "10.1.0.7"],
    ["new", "10.1.0.8"],
  ]);
  // First run noticing the absence: clock starts, nothing deleted.
  const p1 = planSync(desired, existing, {}, 1000, 3600);
  expect(p1.toAdd).toEqual([{ name: "new", ip: "10.1.0.8" }]);
  expect(p1.toDelete).toEqual([]);
  expect(p1.next["gone"].lastSeen).toBe(1000);
  // Still within grace: kept.
  const p2 = planSync(desired, existing, p1.next, 2000, 3600);
  expect(p2.toDelete).toEqual([]);
  // Past grace: deleted and pruned from state.
  const p3 = planSync(desired, existing, p1.next, 5000, 3600);
  expect(p3.toDelete).toEqual([{ name: "gone" }]);
  expect("gone" in p3.next).toBe(false);
});
test("planSync refreshes lastSeen for present hosts and updates IPs immediately", () => {
  const existing = [{ name: "laptop", ip: "10.1.0.70", ttl: 120 }];
  const p = planSync(
    new Map([["laptop", "10.1.0.99"]]),
    existing,
    { laptop: { ip: "10.1.0.70", lastSeen: 100 } },
    2000,
    3600,
  );
  expect(p.toUpdate).toEqual([{ name: "laptop", ip: "10.1.0.99" }]);
  expect(p.next["laptop"]).toEqual({ ip: "10.1.0.99", lastSeen: 2000 });
});

import { expect, test } from "bun:test";
import {
  sanitizeHostname,
  parseKeaLeases,
  buildDesiredRecords,
  diffRecords,
  isSnapshotTrustworthy,
} from "./src/sync";
test("sanitize lowercases and rejects junk", () => {
  expect(sanitizeHostname("My_Laptop ")).toBe("my-laptop");
  expect(sanitizeHostname("")).toBeNull();
  expect(sanitizeHostname("***")).toBeNull();
  expect(sanitizeHostname("-bad-")).toBeNull();
});
test("parse keeps only unexpired allowed-subnet leases", () => {
  const csv = `address,hwaddr,hostname,expire,subnet_id\n10.1.0.70,aa:bb:cc:dd:ee:ff,laptop1,1899999999,1\n10.1.0.71,aa:bb:cc:dd:ee:00,oldlaptop,1000000000,1\n10.1.20.90,aa:bb:cc:dd:ee:11,guestphone,1899999999,20\n`;
  expect(parseKeaLeases(csv, [1], 1800000000)).toEqual([
    { ip: "10.1.0.70", hostname: "laptop1", subnetId: 1 },
  ]);
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

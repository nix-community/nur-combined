// How many files to compile at once when `-j` is not given.
//
// `availableParallelism()` counts SMT threads. A compile is pure computation,
// so two hyperthreads on one core contend for the same execution units rather
// than overlapping stalls: on Linux / x86_64 with 8 cores and 16 threads, over
// 138 Lichess stylesheets, `-j 8` beat `-j 16` — 366 ms against 425 ms through
// this CLI, 208 against 235 through the native binary — and defaulting to the
// core count took that corpus from 444 ms to 364 ms. (Times rather than
// percentages on purpose: "faster by" reads differently depending on which of
// the two you divide by, and both readings appear in this file's history.)
// On a machine without SMT the two counts are equal and nothing changes.
//
// Linux publishes the topology in `/proc/cpuinfo`, which is a read rather than
// a fork. Apple silicon has no SMT, so the logical count is already right
// there; Intel Macs and Windows keep the logical count rather than pay a
// subprocess at start-up for a number that is, at worst, today's default.
import { readFileSync } from "node:fs";
// Default import, NOT a named one: `availableParallelism` only exists on
// Node >= 18.14, and a missing named export fails ESM *linking* — this module
// is reached from the package's `bin`, so the CLI would not start at all on an
// older Node, before any fallback could run. (`_loader.mjs` carries the same
// note for the library entries.)
import os from "node:os";

/**
 * Logical CPUs, the number `-j` used to default to.
 *
 * `os.cpus().length` is the fallback and is NOT the same question: it counts
 * the host's CPUs and ignores the affinity mask, so under `taskset -c 0,1,8,9`
 * on a 16-thread machine it answers 16 where `availableParallelism()` answers
 * 4 (measured 2026-09-17). The package supports Node >= 16 and
 * `availableParallelism` arrived in 18.14, so on part of that range this is
 * the host count — `allowedCpusFromStatus` and the cgroup quota are what put
 * the floor back.
 *
 * Run on the real runtimes rather than reasoned about, 2026-09-17, on a host
 * with 8 physical cores and 16 threads. `defaultJobs()` in each case:
 *
 *                       unrestricted   --cpus=2   --cpuset-cpus=0,1,8,9
 *     v16.20.2 (no API)        8           2                4
 *     v18.20.8                 8           2                4
 *     v22.23.2                 8           2                4
 *
 * Node 16 reaches the same answers with `logicalCpus()` reporting the host's
 * 16 throughout, which is the point: the floor comes from the two files, not
 * from the runtime.
 */
export function logicalCpus(osApi = os) {
  return osApi.availableParallelism ? osApi.availableParallelism() : osApi.cpus().length;
}

/**
 * How many logical CPUs this process may run on, from `/proc/self/status`'s
 * `Cpus_allowed_list` (`0-1,8-9`), or `undefined` if it does not parse.
 *
 * Read on every Node version rather than only the ones missing
 * `availableParallelism`: it is one small file at start-up, and it means the
 * cap does not depend on which Node the user happens to run.
 */
export function allowedCpusFromStatus(text) {
  const line = /^Cpus_allowed_list:\s*(\S+)/m.exec(text);
  if (line === null) return undefined;
  let count = 0;
  for (const part of line[1].split(",")) {
    const [lo, hi] = part.split("-");
    const first = Number(lo);
    const last = hi === undefined ? first : Number(hi);
    if (!Number.isInteger(first) || !Number.isInteger(last) || last < first) return undefined;
    count += last - first + 1;
  }
  return count > 0 ? count : undefined;
}

/**
 * Physical cores from a Linux `/proc/cpuinfo`, or `undefined` when it does not
 * say — containers and VMs often publish no topology at all, and a number
 * derived from nothing is worse than the kernel's own count.
 *
 * A core is a `(physical id, core id)` pair: `core id` alone repeats across
 * sockets.
 *
 * The socket resets at each `processor` record rather than carrying over. On
 * x86 Linux both fields are printed together for every processor, so this
 * changes nothing there; it matters for a file that reports the socket for
 * some processors and not others, where carrying the previous value would
 * file a core under a socket the kernel never claimed. A file that names no
 * socket at all is left alone deliberately — every core then lands under `""`,
 * which is the right answer for the single-socket VMs that report `core id`
 * by itself, and giving up on those would lose them the fix.
 */
export function physicalCoresFromCpuinfo(text) {
  const cores = new Set();
  // Buffered per record rather than inserted on sight: nothing promises that
  // `physical id` is printed before `core id`, and inserting early would file
  // the core under the wrong socket — or under none — if it is not.
  let pkg;
  let core;
  const endOfRecord = () => {
    if (core !== undefined) cores.add(`${pkg ?? ""}/${core}`);
    pkg = undefined;
    core = undefined;
  };
  for (const line of text.split("\n")) {
    const at = line.indexOf(":");
    if (at < 0) continue;
    const key = line.slice(0, at).trim();
    const value = line.slice(at + 1).trim();
    // A record ends at `processor`, and also at a field the current record
    // already has — a file that omits `processor` lines would otherwise fold
    // into a single core.
    if (key === "processor") endOfRecord();
    else if (key === "physical id") {
      if (pkg !== undefined) endOfRecord();
      pkg = value;
    } else if (key === "core id") {
      if (core !== undefined) endOfRecord();
      core = value;
    }
  }
  endOfRecord();
  return cores.size > 0 ? cores.size : undefined;
}

/**
 * CPUs' worth of cgroup CPU *quota*, or `undefined` when there is no limit.
 *
 * A quota is not an affinity mask: `docker run --cpus=2` leaves
 * `Cpus_allowed_list` at the whole machine and writes `200000 100000` to
 * `cpu.max` instead, so the mask says nothing about it.
 *
 * `availableParallelism()` only started accounting for the quota in Node 22,
 * which is later than it is natural to assume. In that container, measured
 * 2026-09-17:
 *
 *     v18.20.8   availableParallelism 16      <- the quota allows 2
 *     v20.20.8   availableParallelism 16
 *     v22.23.2   availableParallelism 2
 *     v24.21.0   availableParallelism 2
 *
 * So this is not a curiosity for Node versions nobody runs: without it, two
 * current LTS lines start eight workers inside a two-CPU limit.
 *
 * `cgroupQuotaFiles` decides which files this reads, including the ones for
 * the process's own cgroup rather than only the root.
 */
export function quotaCpusFromCgroup({ v2, v1Quota, v1Period }) {
  const cpus = (quota, period) => {
    const q = Number(quota);
    const p = Number(period);
    if (!Number.isFinite(q) || !Number.isFinite(p) || q <= 0 || p <= 0) return undefined;
    // Round up: half a CPU of quota is still a reason to run one worker, and
    // rounding down could reach zero.
    return Math.max(1, Math.ceil(q / p));
  };
  if (v2 !== undefined) {
    const [quota, period] = v2.trim().split(/\s+/);
    return quota === "max" ? undefined : cpus(quota, period);
  }
  if (v1Quota !== undefined && v1Period !== undefined) {
    // cgroup v1 writes -1 for "no limit", which the `q <= 0` rejection above
    // already turns into `undefined` — no separate branch for it, because a
    // branch no input can distinguish is a branch no test can hold honest.
    return cpus(v1Quota, v1Period);
  }
  return undefined;
}

/**
 * The default for `-j`, given a platform and a way to read each of the three
 * files that can lower it: the topology, the affinity mask, and the quota.
 */
export function defaultJobs({
  platform = process.platform,
  readCpuinfo = defaultReadCpuinfo,
  readStatus = defaultReadStatus,
  readCgroup = defaultReadCgroup,
  reportedCpus = logicalCpus,
} = {}) {
  const reported = reportedCpus();
  if (platform !== "linux") return reported;
  const status = readStatus();
  const allowed = status === undefined ? undefined : allowedCpusFromStatus(status);
  const quota = tightestQuota(readCgroup());
  // The smallest of the three, because they answer different questions and no
  // single one of them covers the others on every supported Node: what the
  // runtime reports, the affinity mask (`taskset`, a cpuset) and a cgroup CPU
  // quota (`docker --cpus`, a Kubernetes CPU limit, a systemd `CPUQuota=`).
  //
  // Measured rather than assumed, because the two halves arrived in different
  // releases (2026-09-17, a 16-thread host):
  //
  //     Node        mask       quota
  //     18.20.8     yes         no
  //     20.20.2     yes         no
  //     22.23.2     yes        yes
  //     24.21.0     yes        yes
  //
  // `availableParallelism()` has folded the mask in since it appeared in
  // 18.14, and the quota only since 22 — so the quota read below is what two
  // current LTS lines depend on, not just the Nodes without the API at all.
  const logical = Math.min(reported, allowed ?? reported, quota ?? reported);
  const text = readCpuinfo();
  if (text === undefined) return logical;
  const physical = physicalCoresFromCpuinfo(text);
  // The host's core count, capped by what this process may actually use.
  //
  // It is deliberately NOT the number of physical cores inside the affinity
  // mask, which looks more correct and measures much worse. SMT only stops
  // paying once enough cores are in play; restrict the process and the second
  // thread on each core goes back to being worth having. Same corpus and
  // machine as above, best of five, `taskset` masks of whole cores:
  //
  //     cores allowed   1     2     4     6     7     8
  //     SMT is worth  +55%  +50%  +33%   -2%   -6%  -11%
  //
  // so counting cores within the mask would pick 2 where 4 is 50% faster, and
  // 4 where 8 is 33% faster. This rule picked the best of the measured options
  // at every mask size (measured 2026-09-17).
  return physical === undefined ? logical : Math.max(1, Math.min(physical, logical));
}

function defaultReadCpuinfo() {
  try {
    return readFileSync("/proc/cpuinfo", "utf8");
  } catch {
    return undefined;
  }
}

function defaultReadStatus() {
  try {
    return readFileSync("/proc/self/status", "utf8");
  } catch {
    return undefined;
  }
}

/**
 * Every cgroup file worth reading for a quota, deepest first, given the text
 * of `/proc/self/cgroup`.
 *
 * The limit is not necessarily at the root. A container with its own cgroup
 * namespace reports `0::/` and the root file is the answer, which is why
 * reading only the root appeared to work — but a systemd scope on a host
 * reports something like `0::/user.slice/…/run-p166821.scope`, and there the
 * root `cpu.max` does not even exist while the scope's own does. Measured on
 * 2026-09-17 under `systemd-run -p CPUQuota=200%`: root unavailable, own
 * cgroup `200000 100000`. Node 22 and later walk this, and so does Rust;
 * everything earlier is why it is spelled out here.
 *
 * Parents are included because a limit anywhere along the path applies, and
 * the tightest of them is the effective one.
 *
 * cgroup v1 mounts the cpu controller as `cpu` on some distributions and
 * `cpu,cpuacct` on others, so both names are tried.
 *
 * What this does NOT do is discover the mountpoint from
 * `/proc/self/mountinfo`. A hierarchy mounted somewhere other than
 * `/sys/fs/cgroup` — v2 under `/sys/fs/cgroup/unified` in hybrid mode, say —
 * is not found, and the default then falls back to the core count, which is
 * what it was before any of this existed rather than something worse. That
 * trade is deliberate: mount discovery is a second parser whose failure mode
 * is a silently wrong worker count on machines none of this was tested on,
 * and `-j` is one flag away for anyone it matters to.
 */
export function cgroupQuotaFiles(procSelfCgroup) {
  const v2 = [];
  const v1 = [];
  const ancestors = (path) => {
    const parts = path.split("/").filter(Boolean);
    const out = [];
    for (let i = parts.length; i >= 0; i--) out.push("/" + parts.slice(0, i).join("/"));
    return out.map((p) => (p === "/" ? "" : p));
  };

  for (const line of (procSelfCgroup ?? "").split("\n")) {
    // "0::/a/b" for v2, "4:cpu,cpuacct:/a/b" for v1.
    const parts = line.split(":");
    if (parts.length < 3) continue;
    const controllers = parts[1];
    const path = parts.slice(2).join(":");
    if (controllers === "") {
      for (const at of ancestors(path)) v2.push(`/sys/fs/cgroup${at}/cpu.max`);
    } else if (controllers.split(",").includes("cpu")) {
      for (const dir of ["/sys/fs/cgroup/cpu", "/sys/fs/cgroup/cpu,cpuacct"]) {
        for (const at of ancestors(path)) {
          v1.push({
            quota: `${dir}${at}/cpu.cfs_quota_us`,
            period: `${dir}${at}/cpu.cfs_period_us`,
          });
        }
      }
    }
  }
  // The root is a guess for a file that could not be READ, not for one that
  // was read and named no cpu hierarchy. Those are different answers: the
  // second says this process is not in such a hierarchy, and probing the root
  // anyway means reading a limit that belongs to someone else.
  //
  // In practice the v2 root carries no `cpu.max` at all — verified on a host,
  // where the file does not exist, against a container, where the namespace
  // root IS the container's own cgroup and the file is its limit — so the old
  // shape was harmless. Not relying on that is still better than relying on
  // it.
  if (procSelfCgroup === undefined) {
    v2.push("/sys/fs/cgroup/cpu.max");
    for (const dir of ["/sys/fs/cgroup/cpu", "/sys/fs/cgroup/cpu,cpuacct"]) {
      v1.push({ quota: `${dir}/cpu.cfs_quota_us`, period: `${dir}/cpu.cfs_period_us` });
    }
  }
  return { v2, v1 };
}

/** Each candidate's contents, for `tightestQuota`. */
export function cgroupFiles(read) {
  // Passed through undefined-and-all: `cgroupQuotaFiles` distinguishes a file
  // it could not read from one that named no cpu hierarchy.
  const { v2, v1 } = cgroupQuotaFiles(read("/proc/self/cgroup"));
  return [
    ...v2.map((path) => ({ v2: read(path) })),
    ...v1.map(({ quota, period }) => ({ v1Quota: read(quota), v1Period: read(period) })),
  ];
}

/**
 * The smallest quota found anywhere along the hierarchy, because a limit on a
 * parent slice applies just as much as one on the leaf.
 */
export function tightestQuota(readings) {
  const found = readings.map(quotaCpusFromCgroup).filter((n) => n !== undefined);
  return found.length === 0 ? undefined : Math.min(...found);
}

function defaultReadCgroup() {
  return cgroupFiles((path) => {
    try {
      return readFileSync(path, "utf8");
    } catch {
      return undefined;
    }
  });
}

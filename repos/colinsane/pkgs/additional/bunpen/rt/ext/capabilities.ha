// vim: set shiftwidth=2 :
use rt;

export type cap = enum {
  // In a system with the [_POSIX_CHOWN_RESTRICTED] option defined, this
  // overrides the restriction of changing file ownership and group
  // ownership.
  CHOWN = 0,

  // Override all DAC access, including ACL execute access if
  // [_POSIX_ACL] is defined. Excluding DAC access covered by
  // CAP_LINUX_IMMUTABLE.
  DAC_OVERRIDE = 1,

  // Overrides all DAC restrictions regarding read and search on files
  // and directories, including ACL restrictions if [_POSIX_ACL] is
  // defined. Excluding DAC access covered by CAP_LINUX_IMMUTABLE.
  DAC_READ_SEARCH = 2,

  // Overrides all restrictions about allowed operations on files, where
  // file owner ID must be equal to the user ID, except where CAP_FSETID
  // is applicable. It doesn't override MAC and DAC restrictions.
  FOWNER = 3,

  // Overrides the following restrictions that the effective user ID
  // shall match the file owner ID when setting the S_ISUID and S_ISGID
  // bits on that file; that the effective group ID (or one of the
  // supplementary group IDs) shall match the file owner ID when setting
  // the S_ISGID bit on that file; that the S_ISUID and S_ISGID bits are
  // cleared on successful return from chown(2) (not implemented).
  FSETID = 4,

  // Overrides the restriction that the real or effective user ID of a
  // process sending a signal must match the real or effective user ID
  // of the process receiving the signal.
  KILL = 5,

  // Allows setgid(2) manipulation
  // Allows setgroups(2)
  // Allows forged gids on socket credentials passing.
  SETGID = 6,

  // Allows set*uid(2) manipulation (including fsuid).
  // Allows forged pids on socket credentials passing.
  SETUID = 7,

  // Without VFS support for capabilities:
  //   Transfer any capability in your permitted set to any pid,
  //   remove any capability in your permitted set from any pid
  // With VFS support for capabilities (neither of above, but)
  //   Add any capability from current's capability bounding set
  //       to the current process' inheritable set
  //   Allow taking bits out of capability bounding set
  //   Allow modification of the securebits for a process
  SETPCAP = 8,

  // Allow modification of S_IMMUTABLE and S_APPEND file attributes
  LINUX_IMMUTABLE = 9,

  // Allows binding to TCP/UDP sockets below 1024
  // Allows binding to ATM VCIs below 32
  NET_BIND_SERVICE = 10,

  // Allow broadcasting, listen to multicast
  NET_BROADCAST = 11,

  // Allow interface configuration
  // Allow administration of IP firewall, masquerading and accounting
  // Allow setting debug option on sockets
  // Allow modification of routing tables
  // Allow setting arbitrary process / process group ownership on sockets
  // Allow binding to any address for transparent proxying (also via NET_RAW)
  // Allow setting TOS (type of service)
  // Allow setting promiscuous mode
  // Allow clearing driver statistics
  // Allow multicasting
  // Allow read/write of device-specific registers
  // Allow activation of ATM control sockets
  NET_ADMIN = 12,

  // Allow use of RAW sockets
  // Allow use of PACKET sockets
  // Allow binding to any address for transparent proxying (also via NET_ADMIN)
  NET_RAW = 13,

  // Allow locking of shared memory segments
  // Allow mlock and mlockall (which doesn't really have anything to do with IPC)
  IPC_LOCK = 14,

  // Override IPC ownership checks
  IPC_OWNER = 15,

  // Insert and remove kernel modules - modify kernel without limit
  SYS_MODULE = 16,

  // Allow ioperm/iopl access
  // Allow sending USB messages to any device via /dev/bus/usb
  SYS_RAWIO = 17,

  // Allow use of chroot()
  SYS_CHROOT = 18,

  // Allow ptrace() of any process
  SYS_PTRACE = 19,

  // Allow configuration of process accounting
  SYS_PACCT = 20,

  // Allow configuration of the secure attention key
  // Allow administration of the random device
  // Allow examination and configuration of disk quotas
  // Allow setting the domainname
  // Allow setting the hostname
  // Allow mount() and umount(), setting up new smb connection
  // Allow some autofs root ioctls
  // Allow nfsservctl
  // Allow VM86_REQUEST_IRQ
  // Allow to read/write pci config on alpha
  // Allow irix_prctl on mips (setstacksize)
  // Allow flushing all cache on m68k (sys_cacheflush)
  // Allow removing semaphores
  // Used instead of CAP_CHOWN to "chown" IPC message queues, semaphores
  //    and shared memory
  // Allow locking/unlocking of shared memory segment
  // Allow turning swap on/off
  // Allow forged pids on socket credentials passing
  // Allow setting readahead and flushing buffers on block devices
  // Allow setting geometry in floppy driver
  // Allow turning DMA on/off in xd driver
  // Allow administration of md devices (mostly the above, but some
  //    extra ioctls)
  // Allow tuning the ide driver
  // Allow access to the nvram device
  // Allow administration of apm_bios, serial and bttv (TV) device
  // Allow manufacturer commands in isdn CAPI support driver
  // Allow reading non-standardized portions of pci configuration space
  // Allow DDI debug ioctl on sbpcd driver
  // Allow setting up serial ports
  // Allow sending raw qic-117 commands
  // Allow enabling/disabling tagged queuing on SCSI controllers and sending
  //    arbitrary SCSI commands
  // Allow setting encryption key on loopback filesystem
  // Allow setting zone reclaim policy
  // Allow everything under CAP_BPF and CAP_PERFMON for backward compatibility
  SYS_ADMIN = 21,

  // Allow use of reboot()
  SYS_BOOT = 22,

  // Allow raising priority and setting priority on other (different UID) processes
  // Allow use of FIFO and round-robin (realtime) scheduling on own
  //    processes and setting the scheduling algorithm used by another process.
  // Allow setting cpu affinity on other processes
  // Allow setting realtime ioprio class
  // Allow setting ioprio class on other processes
  SYS_NICE = 23,

  // Override resource limits. Set resource limits.
  // Override quota limits.
  // Override reserved space on ext2 filesystem
  // Modify data journaling mode on ext3 filesystem (uses journaling resources)
  // NOTE: ext2 honors fsuid when checking for resource overrides, so
  //    you can override using fsuid too
  // Override size restrictions on IPC message queues
  // Allow more than 64hz interrupts from the real-time clock
  // Override max number of consoles on console allocation
  // Override max number of keymaps
  // Control memory reclaim behavior
  SYS_RESOURCE = 24,

  // Allow manipulation of system clock
  // Allow irix_stime on mips
  // Allow setting the real-time clock
  SYS_TIME = 25,

  // Allow configuration of tty devices
  // Allow vhangup() of tty
  SYS_TTY_CONFIG = 26,

  // Allow the privileged aspects of mknod()
  MKNOD = 27,

  // Allow taking of leases on files
  LEASE = 28,

  // Allow writing the audit log via unicast netlink socket
  AUDIT_WRITE = 29,

  // Allow configuration of audit via unicast netlink socket
  AUDIT_CONTROL = 30,

  // Set or remove capabilities on files.
  // Map uid=0 into a child user namespace.
  SETFCAP = 31,

  // Override MAC access.
  // The base kernel enforces no MAC policy.
  // An LSM may enforce a MAC policy, and if it does and it chooses
  // to implement capability based overrides of that policy, this is
  // the capability it should use to do so.
  MAC_OVERRIDE = 32,

  // Allow MAC configuration or state changes.
  // The base kernel requires no MAC configuration.
  // An LSM may enforce a MAC policy, and if it does and it chooses
  // to implement capability based checks on modifications to that
  // policy or the data required to maintain it, this is the
  // capability it should use to do so.
  MAC_ADMIN = 33,

  // Allow configuring the kernel's syslog (printk behaviour)
  SYSLOG = 34,

  // Allow triggering something that will wake the system
  WAKE_ALARM = 35,

  // Allow preventing system suspends
  BLOCK_SUSPEND = 36,

  // Allow reading the audit log via multicast netlink socket
  AUDIT_READ = 37,

  // Allow system performance and observability privileged operations
  // using perf_events, i915_perf and other kernel subsystems
  PERFMON = 38,

  // CAP_BPF allows the following BPF operations:
  // - Creating all types of BPF maps
  // - Advanced verifier features
  //   - Indirect variable access
  //   - Bounded loops
  //   - BPF to BPF function calls
  //   - Scalar precision tracking
  //   - Larger complexity limits
  //   - Dead code elimination
  //   - And potentially other features
  // - Loading BPF Type Format (BTF) data
  // - Retrieve xlated and JITed code of BPF programs
  // - Use bpf_spin_lock() helper
  //
  // CAP_PERFMON relaxes the verifier checks further:
  // - BPF progs can use of pointer-to-integer conversions
  // - speculation attack hardening measures are bypassed
  // - bpf_probe_read to read arbitrary kernel memory is allowed
  // - bpf_trace_printk to print kernel memory is allowed
  //
  // CAP_SYS_ADMIN is required to use bpf_probe_write_user.
  //
  // CAP_SYS_ADMIN is required to iterate system wide loaded
  // programs, maps, links, BTFs and convert their IDs to file descriptors.
  //
  // CAP_PERFMON and CAP_BPF are required to load tracing programs.
  // CAP_NET_ADMIN and CAP_BPF are required to load networking programs.
  BPF = 39,

  // Allow checkpoint/restore related operations
  // Allow PID selection during clone3()
  // Allow writing to ns_last_pid
  CHECKPOINT_RESTORE = 40,
};
// bitset of the above. cap::FOO corresponds to the *index* of a bit here.
// e.g. `let c: caps = (1 << cap::SYS_ADMIN)`
export type caps = u64;


type user_cap_header = struct {
  // set to _LINUX_CAPABILITY_VERSION_$n
  version: u32,
  // typically 0, or (equivalently) gettid()
  pid: int,
};

type user_cap_data = struct {
  effective: u32,
  permitted: u32,
  inheritable: u32,
};

const _LINUX_CAPABILITY_VERSION_1: u32 = 0x19980330;
const _LINUX_CAPABILITY_U32S_1: u32 = 1;

// V2 added in Linux 2.6.25; deprecated
const _LINUX_CAPABILITY_VERSION_2: u32 = 0x20071026;
const _LINUX_CAPABILITY_U32S_2: u32 = 2;

// V3 added in Linux 2.6.26
const _LINUX_CAPABILITY_VERSION_3: u32 = 0x20080522;
const _LINUX_CAPABILITY_U32S_3: u32 = 2;


export fn no_new_privs() (void | rt::errno) = {
  rt::prctl(rt::PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)?;
};

export fn capset(eff: caps, prm: caps, inh: caps) (void | rt::errno) = {
  let hdr = user_cap_header {
    version = _LINUX_CAPABILITY_VERSION_3,
    pid = 0,  //< 0 means to apply this to self
  };

  // the API has some legacy such that we have to provide the lower 32 caps and
  // the upper 32 separately:
  let eff_lo = (eff & 0xFFFFFFFF): u32;
  let eff_hi = ((eff << 32) & 0xFFFFFFFF): u32;
  let prm_lo = (prm & 0xFFFFFFFF): u32;
  let prm_hi = ((prm << 32) & 0xFFFFFFFF): u32;
  let inh_lo = (inh & 0xFFFFFFFF): u32;
  let inh_hi = ((inh << 32) & 0xFFFFFFFF): u32;
  let data: [2]user_cap_data = [
    (user_cap_data {
      effective = eff_lo,
      permitted = prm_lo,
      inheritable = inh_lo,
    }),
    (user_cap_data {
      effective = eff_hi,
      permitted = prm_hi,
      inheritable = inh_hi,
    }),
  ];
  syscall(rt::SYS_capset, &hdr: uintptr, &data: uintptr)?;
};

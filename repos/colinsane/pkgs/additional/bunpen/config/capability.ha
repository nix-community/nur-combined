// vim: set shiftwidth=2 :

use ascii;
use rt::ext;
use strings;

fn capability_fromstr(v: str) (rt::ext::cap | error) = {
  // strip leading CAP_ and allow either form.
  if (len(v) > 4 && ascii::strcasecmp(strings::sub(v, 0, 4), "CAP_") == 0)
    v = strings::sub(v, 4);

  if (ascii::strcasecmp(v, "AUDIT_CONTROL") == 0)
    return rt::ext::cap::AUDIT_CONTROL;
  if (ascii::strcasecmp(v, "AUDIT_READ") == 0)
    return rt::ext::cap::AUDIT_READ;
  if (ascii::strcasecmp(v, "AUDIT_WRITE") == 0)
    return rt::ext::cap::AUDIT_WRITE;
  if (ascii::strcasecmp(v, "BLOCK_SUSPEND") == 0)
    return rt::ext::cap::BLOCK_SUSPEND;
  if (ascii::strcasecmp(v, "BPF") == 0)
    return rt::ext::cap::BPF;
  if (ascii::strcasecmp(v, "CHECKPOINT_RESTORE") == 0)
    return rt::ext::cap::CHECKPOINT_RESTORE;
  if (ascii::strcasecmp(v, "CHOWN") == 0)
    return rt::ext::cap::CHOWN;
  if (ascii::strcasecmp(v, "DAC_OVERRIDE") == 0)
    return rt::ext::cap::DAC_OVERRIDE;
  if (ascii::strcasecmp(v, "DAC_READ_SEARCH") == 0)
    return rt::ext::cap::DAC_READ_SEARCH;
  if (ascii::strcasecmp(v, "FOWNER") == 0)
    return rt::ext::cap::FOWNER;
  if (ascii::strcasecmp(v, "FSETID") == 0)
    return rt::ext::cap::FSETID;
  if (ascii::strcasecmp(v, "IPC_LOCK") == 0)
    return rt::ext::cap::IPC_LOCK;
  if (ascii::strcasecmp(v, "IPC_OWNER") == 0)
    return rt::ext::cap::IPC_OWNER;
  if (ascii::strcasecmp(v, "KILL") == 0)
    return rt::ext::cap::KILL;
  if (ascii::strcasecmp(v, "LEASE") == 0)
    return rt::ext::cap::LEASE;
  if (ascii::strcasecmp(v, "LINUX_IMMUTABLE") == 0)
    return rt::ext::cap::LINUX_IMMUTABLE;
  if (ascii::strcasecmp(v, "MAC_ADMIN") == 0)
    return rt::ext::cap::MAC_ADMIN;
  if (ascii::strcasecmp(v, "MAC_OVERRIDE") == 0)
    return rt::ext::cap::MAC_OVERRIDE;
  if (ascii::strcasecmp(v, "MKNOD") == 0)
    return rt::ext::cap::MKNOD;
  if (ascii::strcasecmp(v, "NET_ADMIN") == 0)
    return rt::ext::cap::NET_ADMIN;
  if (ascii::strcasecmp(v, "NET_BIND_SERVICE") == 0)
    return rt::ext::cap::NET_BIND_SERVICE;
  if (ascii::strcasecmp(v, "NET_BROADCAST") == 0)
    return rt::ext::cap::NET_BROADCAST;
  if (ascii::strcasecmp(v, "NET_RAW") == 0)
    return rt::ext::cap::NET_RAW;
  if (ascii::strcasecmp(v, "PERFMON") == 0)
    return rt::ext::cap::PERFMON;
  if (ascii::strcasecmp(v, "SETFCAP") == 0)
    return rt::ext::cap::SETFCAP;
  if (ascii::strcasecmp(v, "SETGID") == 0)
    return rt::ext::cap::SETGID;
  if (ascii::strcasecmp(v, "SETPCAP") == 0)
    return rt::ext::cap::SETPCAP;
  if (ascii::strcasecmp(v, "SETUID") == 0)
    return rt::ext::cap::SETUID;
  if (ascii::strcasecmp(v, "SYS_ADMIN") == 0)
    return rt::ext::cap::SYS_ADMIN;
  if (ascii::strcasecmp(v, "SYS_BOOT") == 0)
    return rt::ext::cap::SYS_BOOT;
  if (ascii::strcasecmp(v, "SYS_CHROOT") == 0)
    return rt::ext::cap::SYS_CHROOT;
  if (ascii::strcasecmp(v, "SYS_MODULE") == 0)
    return rt::ext::cap::SYS_MODULE;
  if (ascii::strcasecmp(v, "SYS_NICE") == 0)
    return rt::ext::cap::SYS_NICE;
  if (ascii::strcasecmp(v, "SYS_PACCT") == 0)
    return rt::ext::cap::SYS_PACCT;
  if (ascii::strcasecmp(v, "SYS_PTRACE") == 0)
    return rt::ext::cap::SYS_PTRACE;
  if (ascii::strcasecmp(v, "SYS_RAWIO") == 0)
    return rt::ext::cap::SYS_RAWIO;
  if (ascii::strcasecmp(v, "SYS_RESOURCE") == 0)
    return rt::ext::cap::SYS_RESOURCE;
  if (ascii::strcasecmp(v, "SYS_TIME") == 0)
    return rt::ext::cap::SYS_TIME;
  if (ascii::strcasecmp(v, "SYS_TTY_CONFIG") == 0)
    return rt::ext::cap::SYS_TTY_CONFIG;
  if (ascii::strcasecmp(v, "SYSLOG") == 0)
    return rt::ext::cap::SYSLOG;
  if (ascii::strcasecmp(v, "WAKE_ALARM") == 0)
    return rt::ext::cap::WAKE_ALARM;

  return error;
};

// return true if `s` parses to `expect`
fn _parse_eq(s: str, expect: (rt::ext::cap | error)) bool = {
  let got = capability_fromstr(s);
  return match (expect) {
    case let c: rt::ext::cap => yield match (got) {
      case let c2: rt::ext::cap => yield c2 == c;
      case => yield false;
    };
    case error => yield match (got) {
      case error => yield true;  // both errors
      case => yield false;
    };
  };
};

@test fn cap_from_str_good() void = {
  assert(_parse_eq("SYS_ADMIN", rt::ext::cap::SYS_ADMIN));
  assert(_parse_eq("CAP_SYS_ADMIN", rt::ext::cap::SYS_ADMIN));

  assert(_parse_eq("sys_admin", rt::ext::cap::SYS_ADMIN));
  assert(_parse_eq("cap_sys_admin", rt::ext::cap::SYS_ADMIN));

  assert(_parse_eq("CAP_sys_admin", rt::ext::cap::SYS_ADMIN));
  assert(_parse_eq("cap_SYS_ADMIN", rt::ext::cap::SYS_ADMIN));
};

@test fn cap_from_str_bad() void = {
  assert(_parse_eq("CAP_SYS_ADMIN_AND_MORE", error));
  assert(_parse_eq("SYS_ADMIN_CAP", error));
  assert(_parse_eq("SYS", error));
  assert(_parse_eq("", error));
};

{
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  ProtectKernelLogs = true;
  ProtectControlGroups = true;
  ProtectClock = true;
  LockPersonality = true;
  RestrictRealtime = true;
  MemoryDenyWriteExecute = true;
  SystemCallFilter = [
    "~@aio"
    "~@chown"
    "~@clock"
    "~@cpu-emulation"
    "~@debug"
    "~@keyring"
    "~@memlock"
    "~@module"
    "~@mount"
    "~@obsolete"
    "~@pkey"
    "~@privileged"
    "~@raw-io"
    "~@reboot"
    "~@resources"
    "~@setuid"
    "~@swap"
  ];
  SystemCallErrorNumber = "EPERM";
}

# Systemd hardening for a network daemon confined to one writable state directory.
# Modules opt in through `nixos.serviceConfig`; the renderer never imposes it.
# Callers add their own `ReadWritePaths`.
{
  CapabilityBoundingSet = [""];
  NoNewPrivileges = true;
  PrivateDevices = true;
  PrivateTmp = true;
  ProtectControlGroups = true;
  ProtectKernelLogs = true;
  ProtectKernelModules = true;
  ProtectKernelTunables = true;
  ProtectSystem = "strict";
  RestrictSUIDSGID = true;
}

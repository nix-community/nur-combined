{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  lists = rec {
    foldmap = seed: acc: func: list:
      let
        acc' = if acc == [] then [seed] else acc;
        x = head list;
        xs = tail list;
      in if list == [] then acc
         else acc ++ (foldmap seed [(func x acc')] func xs);
  };
  systemd = {
    default = {
      LockPersonality = true;
      PrivateIPC = true;
      PrivateMounts = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
    };
    dynamic = {
      PrivateTmp = true;
      RemoveIPC = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      RestrictSUIDSGID = true;
    };
  };
}

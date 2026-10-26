{
  config,
  lib,
  pkgs,
  cfg,
  common,
  outputs,
}:
{
  name,
  w,
  user,
  network,
  egressSocket,
}:
let
  inherit (common) base appName privateTmp;
in
outputs.empty
// {
  # Reject declarations that would deploy with weaker isolation than
  # they appear to request.
  assertions = [
    {
      assertion = builtins.match "[a-z][a-z0-9-]*" name != null && builtins.stringLength user < 32;
      message = "realm.workloads.${name}: use a short lowercase workload name.";
    }
    {
      assertion = w.user != "root" && w.group != "root";
      message = "realm.workloads.${name}: workloads must have an unprivileged user and group.";
    }
    {
      assertion = lib.hasPrefix "spiffe://${cfg.trustDomain}/" w.spiffeID;
      message = "realm.workloads.${name}: identity must belong to the configured trust domain.";
    }
    {
      assertion =
        builtins.length (lib.unique (map (i: i.port) (builtins.attrValues w.ingress)))
        == builtins.length (builtins.attrNames w.ingress);
      message = "realm.workloads.${name}: ingress ports must be unique.";
    }
    {
      assertion = w.runtime != "systemd" || (config.systemd.services.${appName w}.enable or false);
      message = "realm.workloads.${name}: the application unit must exist and be enabled.";
    }
  ];
  # Three identities: the application (<user>/<group>), one proxy
  # account per workload, and the shared realm-proxies group whose
  # members may read the SPIRE Agent socket.
  userGroups.${user} = { };
  userGroups.${w.group} = { };
  users.${w.user} = {
    isSystemUser = true;
    group = w.group;
  };
  users.${user} = {
    isSystemUser = true;
    group = user;
    extraGroups = [ "realm-proxies" ];
  };
  # egress is reachable by the application group, ingress only by the
  # proxy account, and both hold sockets rather than plain files.
  tmpfiles = [
    "d ${base name} 0755 root root -"
    "d ${base name}/egress 0750 root ${w.group} -"
    "d ${base name}/ingress 0750 root ${user} -"
    # `d` sets ownership only when it creates the directory. A workload
    # whose group changes — a native gateway replacing the proxy account
    # it used to run as — would keep the old group, and the application
    # could no longer traverse the directory even though the sockets
    # inside are recreated with the new one. `z` re-applies the group to
    # the existing directory and, unlike `Z`, does not touch the sockets.
    "z ${base name}/egress 0750 root ${w.group} -"
    "z ${base name}/ingress 0750 root ${user} -"
  ];
  # Namespace holder. Socket units bind inside this namespace, so it
  # must exist before sockets.target and outlive every unit that joins
  # it. It runs nothing but sleep, and DefaultDependencies = false keeps
  # it out of the normal boot and shutdown ordering.
  services = lib.mkMerge [
    (lib.optionalAttrs (w.isolation.privateNetwork && (w.runtime == "systemd" || w.socksProxy.enable)) {
      "realm-net-${name}" = {
        description = "Private loopback namespace for ${name}";
        wantedBy = [ "multi-user.target" ];
        before = [ "sockets.target" ];
        after = [ "systemd-tmpfiles-setup.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          PrivateNetwork = true;
          PrivateTmp = true;
          DynamicUser = true;
          NoNewPrivileges = true;
          CapabilityBoundingSet = "";
        };
      };
    })
    (lib.optionalAttrs (w.runtime == "systemd") {
      ${appName w} = lib.mkMerge [
        (lib.optionalAttrs w.isolation.privateNetwork network)
        {
          # The application keeps its private namespace and gets a
          # read-only /run, so the Agent socket stays invisible. Only the
          # paths listed below are mounted back.
          serviceConfig = {
            PrivateNetwork = w.isolation.privateNetwork;
            NoNewPrivileges = true;
            CapabilityBoundingSet = lib.mkDefault "";
            RestrictNamespaces = true;
            PrivateTmp = true;
            SystemCallArchitectures = "native";
            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];
            # Hide host runtime sockets, then expose only declared capabilities.
            TemporaryFileSystem = [
              "/run:ro"
              privateTmp
            ];
            BindReadOnlyPaths = [
              "-/run/credentials/${w.unit}"
              "-/run/systemd/notify"
              "-/run/current-system"
            ]
            ++ lib.unique (lib.mapAttrsToList (route: e: builtins.dirOf (egressSocket route e)) w.egress)
            ++ w.isolation.allowUnixSockets
            # Aliases keep the original hostnames for SNI and certificate
            # verification while the address points at a local adapter.
            ++ lib.optional (w.isolation.hosts != { }) (
              let
                aliases = pkgs.writeText "realm-${name}-host-aliases" (
                  lib.concatStrings (lib.mapAttrsToList (host: address: "${address} ${host}\n") w.isolation.hosts)
                );
                hosts = pkgs.runCommand "realm-${name}-hosts" { } ''
                  # Remove inherited names that are overridden, including other address families.
                  awk '
                    NR == FNR {
                      for (i = 2; i <= NF; i++) replaced[tolower($i)] = 1
                      print
                      next
                    }
                    /^[[:space:]]*(#|$)/ { print; next }
                    {
                      line = $1; names = 0
                      for (i = 2; i <= NF && substr($i, 1, 1) != "#"; i++) {
                        if (!(tolower($i) in replaced)) { line = line " " $i; names++ }
                      }
                      if (names > 0) print line
                    }
                  ' ${aliases} ${config.environment.etc.hosts.source} > "$out"
                '';
              in
              "${hosts}:/etc/hosts"
            );
            BindPaths = w.isolation.runtimePaths;
          };
        }
      ];
    })
  ];
}

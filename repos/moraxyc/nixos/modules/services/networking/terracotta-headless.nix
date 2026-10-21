{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.terracottaHeadless;

  alphabet = lib.stringToCharacters "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ";
  indices = lib.listToAttrs (
    lib.imap0 (index: character: lib.nameValuePair character index) alphabet
  );
  mod7 = n: lib.mod n 7;
  hexValue = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    a = 10;
    b = 11;
    c = 12;
    d = 13;
    e = 14;
    f = 15;
  };

  codePattern = "U/([0-9A-HJ-NP-Z]{4})-([0-9A-HJ-NP-Z]{4})-([0-9A-HJ-NP-Z]{4})-([0-9A-HJ-NP-Z]{4})";

  codeFromSeed =
    seed:
    let
      digest = builtins.hashString "sha256" seed;
      byteAt =
        index:
        16 * hexValue.${builtins.substring (2 * index) 1 digest}
        + hexValue.${builtins.substring (2 * index + 1) 1 digest};
      first15 = builtins.genList (index: lib.mod (byteAt index) 34) 15;
      remainder = lib.foldl' (
        acc: index:
        let
          digit = builtins.elemAt first15 index;
        in
        mod7 (acc + (if lib.mod index 2 == 0 then digit else 7 - mod7 digit))
      ) 0 (lib.range 0 14);
      last = remainder + 7 * (lib.mod (byteAt 15) 4);
      encoded = lib.concatMapStrings (index: builtins.elemAt alphabet index) (first15 ++ [ last ]);
    in
    "U/${builtins.substring 0 4 encoded}-${builtins.substring 4 4 encoded}-${builtins.substring 8 4 encoded}-${
      builtins.substring 12 4 encoded
    }";

  codeGroups = code: builtins.match codePattern code;

  codeParts =
    code:
    let
      groups = codeGroups code;
    in
    if groups == null then
      [
        "0000"
        "0000"
        "0000"
        "0000"
      ]
    else
      groups;

  isValidCode =
    code:
    let
      groups = codeGroups code;
      digits = lib.imap0 (index: character: {
        inherit index;
        value = indices.${character};
      }) (if groups == null then [ ] else lib.stringToCharacters (lib.concatStrings groups));
      remainder = lib.foldl' (
        accumulated: item:
        mod7 (accumulated + (if lib.mod item.index 2 == 0 then item.value else 7 - mod7 item.value))
      ) 0 digits;
    in
    groups != null && remainder == 0;

  instanceModule =
    { config, ... }:
    {
      options = {
        code = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Fixed Terracotta U/ room code. Set exactly one of code or codeSeed.
            Treat it as a bearer credential; avoid publishing it.
          '';
        };

        codeSeed = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Deterministically derive a valid Terracotta room code from a private
            seed. Set exactly one of code or codeSeed. The resulting network secret
            is included in the generated EasyTier configuration in the Nix store.
          '';
        };

        resolvedCode = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          description = "The canonical Terracotta U/ room code, supplied or derived from codeSeed.";
        };

        minecraftPort = lib.mkOption {
          type = lib.types.port;
          default = 25565;
        };

        scaffoldingPort = lib.mkOption {
          type = lib.types.port;
          default = 13448;
        };

        peers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "tcp://public0.terracotta.glavo.site:21010"
            "tcp://public1.terracotta.glavo.site:21010"
            "tcp://public.easytier.top:11010"
            "tcp://public2.easytier.cn:54321"
          ];
          description = "EasyTier discovery peers shared with Terracotta clients.";
        };
      };

      config.resolvedCode =
        if config.code != null then
          lib.toUpper config.code
        else if config.codeSeed != null then
          codeFromSeed config.codeSeed
        else
          "";
    };

  scaffoldingPorts = map (instance: instance.scaffoldingPort) (builtins.attrValues cfg.instances);
in
{
  options.services.terracottaHeadless.instances = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule instanceModule);
    default = { };
    description = "Terracotta headless service instances.";
  };

  config = {
    assertions =
      lib.concatLists (
        lib.mapAttrsToList (
          name: instance:
          let
            exactlyOne = (instance.code == null) != (instance.codeSeed == null);
          in
          [
            {
              assertion = exactlyOne;
              message = "services.terracottaHeadless.instances.${name}: set exactly one of code or codeSeed.";
            }
            {
              assertion = !exactlyOne || isValidCode instance.resolvedCode;
              message = "services.terracottaHeadless.instances.${name}: code must be a canonical Terracotta U/ room code with a valid checksum.";
            }
          ]
        ) cfg.instances
      )
      ++ [
        {
          assertion = lib.length (lib.unique scaffoldingPorts) == lib.length scaffoldingPorts;
          message = "services.terracottaHeadless.instances: each instance must use a unique scaffoldingPort.";
        }
      ];

    services.easytier = lib.mkIf (cfg.instances != { }) {
      enable = true;

      instances = lib.mapAttrs (
        _name: instance:
        let
          parts = codeParts instance.resolvedCode;
        in
        {
          settings = {
            hostname = "scaffolding-mc-server-${toString instance.scaffoldingPort}";
            network_name = "scaffolding-mc-${builtins.elemAt parts 0}-${builtins.elemAt parts 1}";
            network_secret = "${builtins.elemAt parts 2}-${builtins.elemAt parts 3}";
            ipv4 = "10.144.144.1/24";
            listeners = [
              "tcp://0.0.0.0:0"
              "udp://0.0.0.0:0"
            ];
            peers = instance.peers;
          };

          extraSettings = {
            flags = {
              no_tun = true;
              data_compress_algo = 2;
              multi_thread = true;
              latency_first = true;
              enable_kcp_proxy = true;
              p2p_only = true;
            };
            tcp_whitelist = [
              (toString instance.scaffoldingPort)
              (toString instance.minecraftPort)
            ];
            udp_whitelist = [ (toString instance.minecraftPort) ];
          };
        }
      ) cfg.instances;
    };

    systemd.services = lib.mapAttrs' (
      name: instance:
      lib.nameValuePair "terracotta-headless-${name}" {
        description = "Terracotta headless scaffolding server (${name})";
        wantedBy = [ "multi-user.target" ];
        upheldBy = [ "easytier-${name}.service" ];
        after = [ "easytier-${name}.service" ];
        bindsTo = [ "easytier-${name}.service" ];
        partOf = [ "easytier-${name}.service" ];

        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.python3}/bin/python3 -u ${./terracotta-scaffolding.py} --port ${toString instance.scaffoldingPort} --minecraft-port ${toString instance.minecraftPort}";
          Restart = "always";
          RestartSec = 1;
          DynamicUser = true;
          AmbientCapabilities = lib.optional (instance.scaffoldingPort < 1024) "CAP_NET_BIND_SERVICE";
          CapabilityBoundingSet = lib.optional (instance.scaffoldingPort < 1024) "CAP_NET_BIND_SERVICE";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
        };
      }
    ) cfg.instances;
  };
}

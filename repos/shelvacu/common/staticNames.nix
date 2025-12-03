{
  lib,
  vacuModuleType,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  domainPartRegex = "[[:alnum:]]([[:alnum:]-]{0,61}[[:alnum:]])?";
  domainRegex = ''^${domainPartRegex}(\.${domainPartRegex})*$'';
  domainType = types.strMatching domainRegex;
  hostsLines = lib.pipe config.vacu.staticNames [
    (lib.mapAttrsToList (k: v: [ k ] ++ v))
    (lib.filter (v: (builtins.length v) > 1))
    (map (lib.concatStringsSep " "))
    (lib.concatStringsSep "\n")
  ];
  ip4Seg = ''[0-9]{1,3}'';
  ip4Regex = lib.concatStringsSep ''\.'' [
    ip4Seg
    ip4Seg
    ip4Seg
    ip4Seg
  ];
  ip6Regex = ''[0-9a-fA-F:]+'';
  ipRegex = ''(${ip4Regex})|(${ip6Regex})'';
in
{
  imports = [
    {
      vacu.assertions = map (ip: {
        assertion = (builtins.match ipRegex ip) != null;
        message = ''config.vacu.staticNames: attr name "${ip}" is invalid'';
      }) (builtins.attrNames config.vacu.staticNames);
    }
  ]
  ++ lib.optional (vacuModuleType == "nixos") { networking.hosts = config.vacu.staticNames; }
  ++ lib.optional (vacuModuleType == "nix-on-droid") {
    environment.etc.hosts.text = ''
      127.0.0.1 localhost
      ::1 localhost
      ${hostsLines}
    '';
  };

  options.vacu.staticNames = mkOption {
    type = types.attrsOf (types.listOf domainType);
    default = { };
  };

  config.vacu.staticNames = {
    "205.201.63.13" = [
      "prop"
      "prophecy"
      "prophecy.shelvacu-static"
    ];
    "10.78.79.22" = [ "prophecy.t2d.lan.shelvacu-static" ];
    "178.128.79.152" = [
      "liam"
      "liam.shelvacu-static"
    ];
    "172.83.159.53" = [
      "trip"
      "triple-dezert"
      "triple-dezert.shelvacu-static"
    ];
    "10.78.79.237" = [ "triple-dezert.t2d.lan.shelvacu-static" ];
    "205.201.63.12" = [
      "servo"
      "uninsane-servo.shelvacu-static"
    ];
    "10.78.79.1" = [
      "vnopn"
      "vnopn.shelvacu-static"
      "vnopn.t2d.lan.shelvacu-static"
    ];
    "10.78.79.11" = [
      "mmm"
      "mmm.shelvacu-static"
      "mmm.t2d.lan.shelvacu-static"
    ];
    "10.78.79.69" = [
      "oeto"
      "oeto.shelvacu-static"
      "oeto.t2d.lan.shelvacu-static"
    ];
  };
}

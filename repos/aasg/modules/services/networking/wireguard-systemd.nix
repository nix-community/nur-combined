{ config, lib, utils, pkgs, ... }:
let
  aasgLib = import ../../../lib { inherit lib; };

  inherit (lib) mkEnableOption mkForce mkIf;
  inherit (lib) attrValues concatMap filterAttrs getAttrs mapAttrs mapAttrs' nameValuePair optional optionals pipe versionOlder;
  inherit (aasgLib) capitalizeAttrNames concatMapAttrs concatMapAttrsToList;

  cfg = config.networking.wireguard;
  kernel = config.boot.kernelPackages;

  generatePeerConfig = peer: {
    wireguardPeerConfig = pipe peer [
      (getAttrs [ "publicKey" "presharedKeyFile" "allowedIPs" "endpoint" "persistentKeepalive" ])
      (filterAttrs (name: value: value != null))
      capitalizeAttrNames
    ];
  };

  generateNetdev = interfaceName: interfaceCfg:
    nameValuePair "40-${interfaceName}" {
      netdevConfig = {
        Name = interfaceName;
        Kind = "wireguard";
      };
      wireguardConfig = capitalizeAttrNames (getAttrs [ "privateKeyFile" "listenPort" ] interfaceCfg);
      wireguardPeers = map generatePeerConfig interfaceCfg.peers;
    };

  generateRoute = table: ip: {
    routeConfig = {
      Destination = ip;
      Scope = "link";
      Table = [ table ];
    };
  };

  generateNetwork = interfaceName: interfaceCfg:
    nameValuePair "40-${interfaceName}" {
      name = interfaceName;
      address = interfaceCfg.ips;
      routes =
        let
          peerIPs = concatMap (peer: peer.allowedIPs) interfaceCfg.peers;
          peerRoutes = map (generateRoute interfaceCfg.table) peerIPs;
        in
        optionals interfaceCfg.allowedIPsAsRoutes peerRoutes;
    };

  deviceUnit = interfaceName:
    "sys-subsystem-net-devices-${utils.escapeSystemdPath interfaceName}.device";

  optionalService = cond: name:
    if cond then name else null;

  generateServices = interfaceName: interfaceCfg: {
    ${optionalService (interfaceCfg.preSetup != "") "wireguard-${interfaceName}-prestart"} = {
      wantedBy = [ (deviceUnit interfaceName) ];
      before = [ (deviceUnit interfaceName) ];
      script = interfaceCfg.preSetup;
      serviceConfig.Type = "oneshot";
    };

    ${optionalService (interfaceCfg.postSetup != "") "wireguard-${interfaceName}-poststart"} = {
      wantedBy = [ (deviceUnit interfaceName) ];
      after = [ (deviceUnit interfaceName) ];
      script = interfaceCfg.postSetup;
      serviceConfig.Type = "oneshot";
    };

    ${optionalService (interfaceCfg.postShutdown != "") "wireguard-${interfaceName}-poststop"} = {
      wantedBy = [ (deviceUnit interfaceName) ];
      partOf = [ (deviceUnit interfaceName) ];
      before = [ (deviceUnit interfaceName) ];
      preStop = interfaceCfg.postShutdown;
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
    };

    ${optionalService interfaceCfg.generatePrivateKeyFile "wireguard-${interfaceName}-key"} = {
      description = "WireGuard Tunnel - ${interfaceName} - Key Generator";
      group = "systemd-network";
      wantedBy = [ "systemd-networkd.service" ];
      requiredBy = [ "systemd-networkd.service" ];
      before = [ "systemd-networkd.service" ];
      script = ''
        mkdir -m 0750 -p "${dirOf interfaceCfg.privateKeyFile}"
        if [[ ! -f "${interfaceCfg.privateKeyFile}" ]]; then
          touch "${interfaceCfg.privateKeyFile}"
          chmod 0640 "${interfaceCfg.privateKeyFile}"
          ${pkgs.wireguard}/bin/wg genkey > "${interfaceCfg.privateKeyFile}"
          chmod 0440 "${interfaceCfg.privateKeyFile}"
        fi
      '';
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
    };
  };
in
{
  options = {
    networking.wireguard.enableNetworkd = mkEnableOption "WireGuard via systemd-networkd";
  };

  config = mkIf cfg.enableNetworkd {
    assertions =
      let
        allPeers = concatMapAttrsToList
          (interfaceName: interfaceCfg: map (peer: { inherit interfaceName interfaceCfg peer; }) interfaceCfg.peers)
          cfg.interfaces;
      in
      (attrValues (
        mapAttrs
          (name: value: {
            assertion = value.privateKey == null;
            message = "networking.wireguard.interfaces.${name} has privateKey set, which is not supported by NixOS with systemd-network. Use privateKeyFile instead.";
          })
          cfg.interfaces))
      ++ (attrValues (
        mapAttrs
          (name: value: {
            assertion = value.privateKeyFile != null;
            message = "networking.wireguard.interfaces.${name}.privateKeyFile must be set.";
          })
          cfg.interfaces))
      ++ (map
        ({ interfaceName, peer, ... }: {
          assertion = peer.presharedKeyFile == null;
          message = "networking.wireguard.interfaces.${interfaceName} peer «${peer.publicKey}» has presharedKey set, which is not supported by NixOS with systemd-networkd. Use presharedKeyFile instead.";
        })
        allPeers)
      ++ (attrValues (
        mapAttrs
          (name: value: {
            assertion = (value.interfaceNamespace == null) && (value.socketNamespace == null);
            message = "networking.wireguard.interfaces.${name}.interfaceNamespace or networking.wireguard.interfaces.${name}.socketNamespace is set, but network namespaces are not yet supported by systemd (see https://github.com/systemd/systemd/issues/11103).";
          })
          cfg.interfaces));

    networking.wireguard.enable = mkForce false;
    boot.extraModulePackages = optional (versionOlder kernel.kernel.version "5.6") kernel.wireguard;
    environment.systemPackages = [ pkgs.wireguard-tools ];

    systemd.network.netdevs = mapAttrs' generateNetdev cfg.interfaces;
    systemd.network.networks = mapAttrs' generateNetwork cfg.interfaces;
    systemd.services = concatMapAttrs generateServices cfg.interfaces;
  };
}

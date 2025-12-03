# as of 2023/12/02: complete blockchain is 530 GiB (on-disk size may be larger)
# as of 2025/08/06: on-disk blockchain as reported by `du` is 732 GiB
#
# ports:
# - 8333: for node-to-node communications
# - 8332: rpc (client-to-node)
#
# rpc setup:
# - generate a password
#   - use: <https://github.com/bitcoin/bitcoin/blob/master/share/rpcauth/rpcauth.py>
#     (rpcauth.py is not included in the `'.#bitcoin'` package result)
#   - `wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py`
#   - `python ./rpcauth.py colin`
#   - copy the hash here. it's SHA-256, so safe to be public.
#   - add "rpcuser=colin" and "rpcpassword=<output>" to secrets/servo/bitcoin.conf  (i.e. ~/.bitcoin/bitcoin.conf)
#     - bitcoin.conf docs: <https://github.com/bitcoin/bitcoin/blob/master/doc/bitcoin-conf.md>
# - validate with `bitcoin-cli -netinfo`
{ config, lib, pkgs, sane-lib, ... }:
let
  # bitcoind = config.sane.programs.bitcoind.packageUnwrapped;
  bitcoind = pkgs.bitcoind;
  # wrapper to run bitcoind with the tor onion address as externalip (computed at runtime)
  _bitcoindWithExternalIp = pkgs.writeShellScriptBin "bitcoind" ''
    set -xeu
    externalip="$(cat /var/lib/tor/onion/bitcoind/hostname)"
    exec ${lib.getExe' bitcoind "bitcoind"} "-externalip=$externalip" "$@"
  '';
  # the package i provide to services.bitcoind ends up on system PATH, and used by other tools like clightning.
  # therefore, even though services.bitcoind only needs `bitcoind` binary, provide all the other bitcoin-related binaries (notably `bitcoin-cli`) as well:
  bitcoindWithExternalIp = pkgs.symlinkJoin {
    name = "bitcoind-with-external-ip";
    paths = [ _bitcoindWithExternalIp bitcoind ];
  };
in
{
  sane.persist.sys.byStore.ext = [
    { user = "bitcoind-mainnet"; group = "bitcoind-mainnet"; path = "/var/lib/bitcoind-mainnet"; method = "bind"; }
  ];

  # sane.ports.ports."8333" = {
  #   # this allows other nodes and clients to download blocks from me.
  #   protocol = [ "tcp" ];
  #   visibleTo.wan = true;
  #   description = "colin-bitcoin";
  # };

  services.tor.relay.onionServices.bitcoind = {
    version = 3;
    map = [{
      # by default tor will route public tor port P to 127.0.0.1:P.
      # so if this port is the same as clightning would natively use, then no further config is needed here.
      # see: <https://2019.www.torproject.org/docs/tor-manual.html.en#HiddenServicePort>
      port = 8333;
      # target.port; target.addr;  #< set if tor port != clightning port
    }];
    # allow "tor" group (i.e. bitcoind-mainnet) to read /var/lib/tor/onion/bitcoind/hostname
    settings.HiddenServiceDirGroupReadable = true;
  };

  services.bitcoind.mainnet = {
    enable = true;
    package = bitcoindWithExternalIp;
    rpc.users.colin = {
      # see docs at top of file for how to generate this
      passwordHMAC = "30002c05d82daa210550e17a182db3f3$6071444151281e1aa8a2729f75e3e2d224e9d7cac3974810dab60e7c28ffaae4";
    };
    extraConfig = ''
      # checkblocks: default 6: how many blocks to verify on start
      checkblocks=3
      # don't load the wallet, and disable wallet RPC calls
      disablewallet=1
      # proxy all outbound traffic through Tor
      proxy=127.0.0.1:9050
    '';
    extraCmdlineOptions = [
      # `man bitcoind` for options
      # "-assumevalid=0"  # to perform script validation on all blocks, instead of just the latest checkpoint published by bitcoin-core
      # "-debug"
      # "-debug=estimatefee"
      # "-debug=leveldb"
      # "-debug=http"
      # "-debug=net"
      "-debug=proxy"
      "-debug=rpc"
      # "-debug=validation"
      # "-reindex"  # wipe chainstate, block index, other indices; rebuild from blk*.dat (takes 2.5hrs)
      # "-reindex-chainstate"  # wipe chainstate; rebuild from blk*.dat
    ];
  };

  users.users.bitcoind-mainnet.extraGroups = [ "tor" ];

  systemd.services.bitcoind-mainnet = {
    after = [ "tor.service" ];
    requires = [ "tor.service" ];
    serviceConfig.RestartSec = "30s";  #< default is 0

    # hardening (systemd-analyze security bitcoind-mainnet)
    serviceConfig.StateDirectory = "bitcoind-mainnet";
    serviceConfig.LockPersonality = true;
    serviceConfig.MemoryDenyWriteExecute = "true";
    serviceConfig.NoNewPrivileges = "true";
    serviceConfig.PrivateDevices = "true";
    serviceConfig.PrivateMounts = true;
    serviceConfig.PrivateTmp = "true";
    serviceConfig.PrivateUsers = true;
    serviceConfig.ProcSubset = "pid";
    serviceConfig.ProtectControlGroups = true;
    serviceConfig.ProtectHome = true;
    serviceConfig.ProtectHostname = true;
    serviceConfig.ProtectKernelLogs = true;
    serviceConfig.ProtectKernelModules = true;
    serviceConfig.ProtectKernelTunables = true;
    serviceConfig.ProtectProc = "invisible";
    serviceConfig.ProtectSystem = lib.mkForce "strict";
    serviceConfig.RemoveIPC = true;
    serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
    serviceConfig.RestrictNamespaces = true;
    serviceConfig.RestrictSUIDSGID = true;
    serviceConfig.SystemCallArchitectures = "native";
    serviceConfig.SystemCallFilter = [ "@system-service" ];
  };

  sops.secrets."bitcoin.conf" = {
    mode = "0600";
    owner = "colin";
    group = "users";
  };

  sane.programs.bitcoin-cli.enableFor.user.colin = true;  # for debugging/administration: `bitcoin-cli`
}

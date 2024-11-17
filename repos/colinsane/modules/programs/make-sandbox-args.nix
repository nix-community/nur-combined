{ lib }:
let
  bunpenGenerators = {
    autodetectCliPaths = style: [ "--bunpen-autodetect" style ];
    capability = cap: [ "--bunpen-cap" cap ];
    dns = addr: [ "--bunpen-dns" addr ];
    keepIpc = [ "--bunpen-keep-ipc" ];
    keepPids = [ "--bunpen-keep-pid" ];
    method = m: assert m == "bunpen";
      # smuggle in some defaults
      (lib.concatMap (devnode: [ "--bunpen-path" "/dev/${devnode}" ]) [
        # bwrap *binds* these when you ask for `--dev /dev`.
        "full"
        "null"
        "random"
        "tty"
        "urandom"
        "zero"
        # these are symlinks to /proc/self/fd/...
        "fd"
        "stdin"
        "stdout"
        "stderr"
        # bwrap also does some stuff for /dev/{console,core,ptmx,pts,shm}, i don't need those (yet?)
      ]);
    # if we need any sort of networking, keep /dev/net/tun. pasta will need that to create its tunnel.
    # TODO: is this safe?
    netDev = n: if n == "all" then
      [ "--bunpen-path" "/dev/net/tun" "--bunpen-keep-net" ]
    else
      [ "--bunpen-path" "/dev/net/tun" "--bunpen-net-dev" n ];
    netGateway = netGateway: [ "--bunpen-net-gateway" netGateway ];
    path.unqualified = p: [ "--bunpen-path" p ];
    path.home = p: [ "--bunpen-home-path" p ];
    path.run = p: [ "--bunpen-run-path" p ];
    tryKeepUsers = [ "--bunpen-try-keep-users" ];
    whitelistPwd = [ "--bunpen-path" "." ];
  };
in
{
  method,
  allowedPaths ? [],
  allowedHomePaths ? [],
  allowedRunPaths ? [],
  autodetectCliPaths ? false,
  capabilities ? [],
  dns ? null,
  keepIpc ? false,
  keepPids ? false,
  tryKeepUsers ? false,
  netDev ? null,
  netGateway ? null,
  whitelistPwd ? false,
  extraConfig ? [],
}:
let
  gen = if method == "bunpen" then
    bunpenGenerators
  else
    bunpenGenerators
  ;
  allowPaths = flavor: paths: lib.flatten (builtins.map gen.path."${flavor}" paths);

  capabilityFlags = lib.flatten (builtins.map gen.capability capabilities);

  netItems = lib.optionals (netDev != null) (gen.netDev netDev)
    ++ lib.optionals (netGateway != null) (gen.netGateway netGateway)
    ++ lib.optionals (dns != null) (lib.flatten (builtins.map gen.dns dns))
  ;

in
  (gen.method method)
  ++ netItems
  ++ allowPaths "unqualified" allowedPaths
  ++ allowPaths "home" allowedHomePaths
  ++ allowPaths "run" allowedRunPaths
  ++ capabilityFlags
  ++ lib.optionals (autodetectCliPaths != null) (gen.autodetectCliPaths autodetectCliPaths)
  ++ lib.optionals keepIpc gen.keepIpc
  ++ lib.optionals keepPids gen.keepPids
  ++ lib.optionals tryKeepUsers gen.tryKeepUsers
  ++ lib.optionals whitelistPwd gen.whitelistPwd
  ++ extraConfig

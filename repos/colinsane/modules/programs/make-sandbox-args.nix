{ lib }:
let
  bunpenGenerators = {
    autodetectCliPaths = style: [ "--bunpen-autodetect" style ];
    capability = cap: [ "--bunpen-cap" cap ];
    dbusCall = spec: [ "--bunpen-dbus-call" spec ];
    dbusOwn = interface: [ "--bunpen-dbus-own" interface ];
    dns = addr: [ "--bunpen-dns" addr ];
    env = key: value: [ "--bunpen-env" "${key}=${value}" ];
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
    path.home = p: [ "--bunpen-path" "$HOME/${p}" ];
    path.run = p: [ "--bunpen-path" "$XDG_RUNTIME_DIR/${p}" ];
    tryKeepUsers = [ "--bunpen-try-keep-users" ];
    whitelistPwd = [ "--bunpen-path" "." ];
  };
in
{
  method,
  allowedDbusCall ? [],
  allowedDbusOwn ? [],
  allowedPaths ? [],
  allowedHomePaths ? [],
  allowedRunPaths ? [],
  autodetectCliPaths ? false,
  capabilities ? [],
  dns ? null,
  extraEnv ? {},
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

  envArgs = lib.flatten (lib.mapAttrsToList gen.env extraEnv);

  dbusItems = lib.flatten (lib.map gen.dbusOwn allowedDbusOwn)
    ++ lib.flatten (lib.map gen.dbusCall allowedDbusCall)
  ;

  netItems = lib.optionals (netDev != null) (gen.netDev netDev)
    ++ lib.optionals (netGateway != null) (gen.netGateway netGateway)
    ++ lib.optionals (dns != null) (lib.flatten (builtins.map gen.dns dns))
  ;

in
  (gen.method method)
  ++ dbusItems
  ++ netItems
  ++ allowPaths "unqualified" allowedPaths
  ++ allowPaths "home" allowedHomePaths
  ++ allowPaths "run" allowedRunPaths
  ++ envArgs
  ++ capabilityFlags
  ++ lib.optionals (autodetectCliPaths != null) (gen.autodetectCliPaths autodetectCliPaths)
  ++ lib.optionals keepIpc gen.keepIpc
  ++ lib.optionals keepPids gen.keepPids
  ++ lib.optionals tryKeepUsers gen.tryKeepUsers
  ++ lib.optionals whitelistPwd gen.whitelistPwd
  ++ extraConfig

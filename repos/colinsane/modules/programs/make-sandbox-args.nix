{ lib }:
{
  method,
  allowedPaths ? [],
  allowedHomePaths ? [],
  allowedRunPaths ? [],
  autodetectCliPaths ? false,
  capabilities ? [],
  dns ? null,
  keepPids ? false,
  keepUsers ? false,
  netDev ? null,
  netGateway ? null,
  whitelistPwd ? false,
  extraConfig ? [],
}:
let
  saneboxGenerators = {
    autodetectCliPaths = style: [ "--sanebox-autodetect" style ];
    capability = cap: [ "--sanebox-cap" cap ];
    dns = addr: [ "--sanebox-dns" addr ];
    keepPids = [ "--sanebox-keep-namespace" "pid" ];
    keepUsers = [ "--sanebox-keep-namespace" "user" ];
    method = method: [ "--sanebox-method" method ];
    netDev = netDev: [ "--sanebox-net-dev" netDev ];
    netGateway = netGateway: [ "--sanebox-net-gateway" netGateway ];
    path = p: [ "--sanebox-path" p ];
    path-home = p: [ "--sanebox-home-path" p ];
    path-run = p: [ "--sanebox-run-path" p ];
    whitelistPwd = [ "--sanebox-add-pwd" ];
  };
  bunpenGenerators = {
    method = m: assert m == "bunpen"; [];
    netDev = n: assert n == "all"; [ "--bunpen-keep-net" ];
    path = p: [ "--bunpen-path" p ];
  };
  gen = if method == "bunpen" then
    bunpenGenerators
  else
    saneboxGenerators
  ;
  allowPaths = flavor: paths: lib.flatten (builtins.map gen."path${flavor}" paths);

  capabilityFlags = lib.flatten (builtins.map gen.capability capabilities);

  netItems = lib.optionals (netDev != null) (gen.netDev netDev)
  ++ lib.optionals (netGateway != null) (gen.netGateway netGateway)
  ++ lib.optionals (dns != null) (lib.flatten (builtins.map gen.dns dns))
  ;

in
  (gen.method method)
  ++ netItems
  ++ allowPaths "" allowedPaths
  ++ allowPaths "-home" allowedHomePaths
  ++ allowPaths "-run" allowedRunPaths
  ++ capabilityFlags
  ++ lib.optionals (autodetectCliPaths != null) (gen.autodetectCliPaths autodetectCliPaths)
  ++ lib.optionals keepPids gen.keepPids
  ++ lib.optionals keepUsers gen.keepUsers
  ++ lib.optionals whitelistPwd gen.whitelistPwd
  ++ extraConfig

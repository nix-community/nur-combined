{ lib }:
{ method
, allowedPaths ? []
, allowedHomePaths ? []
, allowedRunPaths ? []
, autodetectCliPaths ? false
, capabilities ? []
, dns ? null
, netDev ? null
, netGateway ? null
, whitelistPwd ? false
, extraConfig ? []
}:
let
  allowPath = flavor: p: [
    "--sanebox${flavor}-path"
    p
  ];
  allowPaths = flavor: paths: lib.flatten (builtins.map (allowPath flavor) paths);

  capabilityFlags = lib.flatten (builtins.map (c: [ "--sanebox-cap" c ]) capabilities);

  netItems = lib.optionals (netDev != null) [
    "--sanebox-net-dev"
    netDev
  ] ++ lib.optionals (netGateway != null) [
    "--sanebox-net-gateway"
    netGateway
  ] ++ lib.optionals (dns != null) (
    lib.flatten (builtins.map
      (addr: [ "--sanebox-dns" addr ])
      dns
    )
  );

in
  [
    "--sanebox-method" method
  ]
  ++ netItems
  ++ allowPaths "" allowedPaths
  ++ allowPaths "-home" allowedHomePaths
  ++ allowPaths "-run" allowedRunPaths
  ++ capabilityFlags
  ++ lib.optionals (autodetectCliPaths != null) [ "--sanebox-autodetect" autodetectCliPaths ]
  ++ lib.optionals whitelistPwd [ "--sanebox-add-pwd" ]
  ++ extraConfig

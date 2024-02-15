{ lib
, writeTextFile }:

{ pkgName
, method
, allowedPaths ? []
, autodetectCliPaths ? false
, capabilities ? []
, dns ? null
, netDev ? null
, whitelistPwd ? false
, extraConfig ? []
}:
let
  allowPath = p: [
    "--sane-sandbox-path"
    p
  ];
  allowPaths = paths: lib.flatten (builtins.map allowPath paths);

  capabilityFlags = lib.flatten (builtins.map (c: [ "--sane-sandbox-cap" c ]) capabilities);

  netItems = lib.optionals (netDev != null) [
    "--sane-sandbox-net"
    netDev
  ] ++ lib.optionals (dns != null) (
    lib.flatten (builtins.map
      (addr: [ "--sane-sandbox-dns" addr ])
      dns
    )
  );

  sandboxFlags = [
    "--sane-sandbox-method" method
  ]
    ++ netItems
    ++ allowPaths allowedPaths
    ++ capabilityFlags
    ++ lib.optionals (autodetectCliPaths != null) [ "--sane-sandbox-autodetect" autodetectCliPaths ]
    ++ lib.optionals whitelistPwd [ "--sane-sandbox-add-pwd" ]
    ++ extraConfig;

in
  writeTextFile {
    name = "${pkgName}-sandbox-profiles";
    destination = "/share/sane-sandboxed/profiles/${pkgName}.profile";
    text = builtins.concatStringsSep "\n" sandboxFlags;
  }

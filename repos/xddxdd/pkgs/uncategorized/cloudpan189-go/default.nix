{
  buildGo122Module,
  lib,
  sources,
  stdenvNoCC,
  writeShellScript,
  ...
}:
let
  inherit (sources.cloudpan189-go) pname version;
  cmd = buildGo122Module {
    inherit pname version;
    inherit (sources.cloudpan189-go) src;
    vendorHash = "sha256-6t4wJqUGJneR6Hv7Dotr4P9MTA1oQcCe/ujDojS0g8s=";

    # Dirty way to fix dependency issue
    overrideModAttrs = _: {
      postInstall = ''
        sed -i '/go:linkname/d' $out/github.com/tickstep/library-go/expires/expires.go
      '';
    };

    doCheck = false;
  };

  startScript = writeShellScript "cloudpan189-go" ''
    export CLOUD189_CONFIG_DIR=''${HOME}/.config/cloudpan189-go
    mkdir -p ''${CLOUD189_CONFIG_DIR}
    exec ${cmd}/bin/cloudpan189-go "$@"
  '';
in
stdenvNoCC.mkDerivation {
  inherit pname version;
  dontUnpack = true;
  postInstall = ''
    install -Dm755 ${startScript} $out/bin/cloudpan189-go
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "CLI for China Telecom 189 Cloud Drive service, implemented in Go";
    homepage = "https://github.com/tickstep/cloudpan189-go";
    license = licenses.asl20;
  };
}

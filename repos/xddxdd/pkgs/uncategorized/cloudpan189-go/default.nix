{ buildGoModule
, lib
, sources
, stdenvNoCC
, writeShellScript
, ...
} @ args:

let
  cmd = buildGoModule rec {
    inherit (sources.cloudpan189-go) pname version src;
    vendorSha256 = "sha256-OHc8iy4HciC5ce0u9LoF7ifjQcGb85h6ZWGcJ3Jh+aE=";

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
  inherit (sources.cloudpan189-go) pname version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${startScript} $out/bin/cloudpan189-go
  '';

  meta = with lib; {
    description = "天翼云盘命令行客户端(CLI)，基于GO语言实现";
    homepage = "https://github.com/tickstep/cloudpan189-go";
    license = licenses.asl20;
  };
}

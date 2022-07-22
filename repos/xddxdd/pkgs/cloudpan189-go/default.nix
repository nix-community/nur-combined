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
    vendorSha256 = "sha256-2zqCpOvrXCv7/oeR6bCLt1esdlMFQ33gD8Y36CghXYo=";

    # Dirty way to fix dependency issue
    preBuild = ''
      chmod -R +w vendor
      sed -i '/go:linkname/d' vendor/github.com/tickstep/library-go/expires/expires.go
      chmod -R -w vendor
    '';

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

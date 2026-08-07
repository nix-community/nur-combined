{
  stdenv,
  lib,
  fetchurl,
  autoPatchelfHook,
  cpio,
  rpm,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ssacli";
  version = "4.21-7.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchurl {
    url = "https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1857046646/v183344/ssacli-${finalAttrs.version}.x86_64.rpm";
    hash = "sha256-qRHfzyhV02/jLwZMfAo0VCgqqdFxBUjmqvPs4r8WfFI=";
  };

  eula = fetchurl {
    url = "https://downloads.linux.hpe.com/SDR/downloads/mcp/EULA.txt";
    hash = "sha256-6v1CtyXV+r6gBwxnsqDde8D0A1ptrlfD7c9mXmCr2W4=";
  };

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    rpm2cpio $src | cpio -idmv
  '';

  nativeBuildInputs = [
    cpio
    rpm
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc
    zlib # TODO: neccesary?
  ];

  installPhase =
    let
      mkBinaryWrapper = name: ''
        cat > $out/bin/${name} <<EOF
        #!/usr/bin/env bash

        export SSACLI_BIN_INSTALLATION_DIR="$out/opt/smartstorageadmin/ssacli/bin/"

        "\$SSACLI_BIN_INSTALLATION_DIR/mklocks.sh" ${name}
        exec "\$SSACLI_BIN_INSTALLATION_DIR/${name}" "\$@"
        EOF
        chmod +x $out/bin/${name}

        cp $out/opt/smartstorageadmin/ssacli/bin/${name} $out/bin/${name}-unwrapped
      '';
    in
    ''
      runHook preInstall

      mkdir -p $out/{bin,share}

      cp -r opt $out/
      cp -r usr/man $out/share/

      install -D -m644 $eula $out/share/licenses/ssacli/EULA.txt

      ${mkBinaryWrapper "ssacli"}
      ${mkBinaryWrapper "ssascripting"}

      runHook postInstall
    '';

  meta = {
    description = "The HPE Smart Storage Administrator CLI is a commandline-based disk configuration program that helps you configure, manage, diagnose, and monitor HPE ProLiant Smart Array Controllers";
    homepage = "https://support.hpe.com/hpsc/swd/public/detail?swItemId=MTX_521fc533ba8f468f9ad9db20e4";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "ssacli";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})

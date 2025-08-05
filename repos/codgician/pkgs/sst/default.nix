{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "sst";
  version = "2.4";

  src =
    let
      ver = builtins.concatStringsSep "-" (builtins.splitVersion version);
    in
    fetchurl {
      url = "https://sdmsdfwdriver.blob.core.windows.net/files/kba-gcc/drivers-downloads/ka-00085/sst--${ver}/sst-cli-linux-deb--${ver}.zip";
      hash = "sha256-COWhFNvepSLr+VXdJXyfZMlVS8QVlViX6CNmokkMQzY=";
    };

  unpackCmd =
    let
      pkgArch =
        if builtins.head (lib.splitString "-" stdenv.hostPlatform.system) == "x86_64" then
          "amd64"
        else
          "i386";
    in
    ''
      unzip -o $curSrc "sst_${version}*_${pkgArch}.deb"
      dpkg -x *.deb source
    '';

  buildInputs = [ stdenv.cc.cc.lib ];
  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    unzip
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv usr/* $out

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "The Solidigm™ Storage Tool, (SST), assists with managing Solidigm™ SSDs.";
    homepage = "https://www.solidigm.com/support-page/drivers-downloads/ka-00085.html";
    platforms = [
      "i386-linux"
      "x86_64-linux"
    ];
    maintainers = with lib.maintainers; [ codgician ];
    mainProgram = "sst";
  };
}

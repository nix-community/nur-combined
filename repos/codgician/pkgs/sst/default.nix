{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  dpkg,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sst";
  version = "2.5";

  src =
    let
      ver = builtins.concatStringsSep "-" (builtins.splitVersion finalAttrs.version);
    in
    fetchurl {
      url = "https://sdmsdfwdriver.blob.core.windows.net/files/kba-gcc/drivers-downloads/ka-00085/sst--${ver}/sst-cli-linux-deb--${ver}.zip";
      hash = "sha256-Y9UZUyrFV7rgqGUP9ZG7n9Je45TayiwmrWpvlrbEn9E=";
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
      unzip -o $curSrc "sst_${finalAttrs.version}*_${pkgArch}.deb"
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
})

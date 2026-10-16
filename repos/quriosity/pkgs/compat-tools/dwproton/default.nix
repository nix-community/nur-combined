{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  steamDisplayName ? "DWProton",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dwproton";
  version = "11.0-14";

  src = fetchzip {
    url = "https://dawn.wine/dawn-winery/dwproton/releases/download/${finalAttrs.pname}-${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}-x86_64.tar.xz";
    hash = "sha256-dXtOdfqIU0wWQ0OXDRbHuFTifGJ7ti+Ij4g+a/RV71Q=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "$toolName" "$steamDisplayName"
  '';

  meta = {
    description = ''
      Dawn Winery's custom Proton fork with fixes for various games

      (This package is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
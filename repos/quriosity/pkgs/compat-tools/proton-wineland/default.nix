{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  steamDisplayName ? "Proton-Wineland",
  variant ?
    {
      x86_64-linux =
        if (stdenvNoCC.hostPlatform.gcc.arch or "") == "x86-64-v3" then
          "x86_64-v3"
        else
          "x86_64";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "proton-wineland: no build for ${stdenvNoCC.hostPlatform.system}"),
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-wineland";
  version = "11.0-20261015";

  inherit (finalAttrs.passthru.variants.${variant}) src toolName;

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

  passthru = {
    variants = {
      "x86_64" = {
        toolName = "proton-wineland-${finalAttrs.version}-x86_64";
        src = fetchzip {
          url = "https://github.com/nanomatters/proton-salkim/releases/download/wineland-${finalAttrs.version}/proton-wineland-${finalAttrs.version}-x86_64.tar.xz";
          hash = "sha256-cacwol74hOi8dEdkH4djbGrSOvP5ILJPxITgzueajus=";
        };
      };
      "x86_64-v3" = {
        toolName = "proton-wineland-${finalAttrs.version}-x86_64_v3";
        src = fetchzip {
          url = "https://github.com/nanomatters/proton-salkim/releases/download/wineland-${finalAttrs.version}/proton-wineland-${finalAttrs.version}-x86_64_v3.tar.xz";
          hash = "sha256-LrL6AV3wdTMKd1zkI4cKjTiKp77+V4ws8RVHsswOnTY=";
        };
      };
    };
  };

  meta = {
    description = ''
      Proton Wineland aims to solve Linux gaming problems through complete solutions rather than accumulating hacks and workarounds for individual games

      (This package is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/nanomatters/proton-salkim";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

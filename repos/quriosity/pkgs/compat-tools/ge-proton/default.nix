{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  steamDisplayName ? "GE-Proton",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ge-proton";
  version = "GE-Proton11-10";

  inherit (finalAttrs.passthru.variants.${stdenvNoCC.hostPlatform.system}) src toolName;

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
      "x86_64-linux" = {
        toolName = "${finalAttrs.version}-x86_64";
        src = fetchzip {
          url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}-x86_64.tar.gz";
          hash = "sha256-pR0MFuBcjr1RZOCJ9aDyWvadGDcXfpZt7loFSNFjWuU=";
        };
      };
      "aarch64-linux" = {
        toolName = "${finalAttrs.version}-aarch64";
        src = fetchzip {
          url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${finalAttrs.version}/${finalAttrs.version}-aarch64.tar.gz";
          hash = "sha256-DScCX0kDKZ4xJR2D6qaYG48KliGBCKc1pDZR8EfbDcw=";
        };
      };
    };
  };

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components.

      (This package is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/GloriousEggroll/proton-ge-custom";
    license = lib.licenses.bsd3;
    platforms = builtins.attrNames finalAttrs.passthru.variants;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
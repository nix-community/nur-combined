{
  lib,
  stdenvNoCC,
  fetchzip,
  writeScript,
  steamDisplayName ? "Proton-CachyOS",
  variant ?
    {
      x86_64-linux =
        if (stdenvNoCC.hostPlatform.gcc.arch or "") == "x86-64-v3" then
          "x86_64-v3"
        else
          "x86_64";
      aarch64-linux = "aarch64";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "proton-cachyos: no build for ${stdenvNoCC.hostPlatform.system}"),
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-cachyos";
  version = "11.0-20261005";

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
        toolName = "proton-cachyos-${finalAttrs.version}-slr-x86_64";
        src = fetchzip {
          url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64.tar.xz";
          hash = "sha256-qcNHgFPIG6c3q53dyeZ18fZu+cBXzs5npyxgj/WIhkg=";
        };
      };
      "x86_64-v3" = {
        toolName = "proton-cachyos-${finalAttrs.version}-slr-x86_64_v3";
        src = fetchzip {
          url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-x86_64_v3.tar.xz";
          hash = "sha256-LlAnK4fAyLrWF+Z0L9Ft4kwfoSB+g+0o9XNvKlOSZXg=";
        };
      };
      "aarch64" = {
        toolName = "proton-cachyos-${finalAttrs.version}-slr-arm64";
        src = fetchzip {
          url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}-slr/proton-cachyos-${finalAttrs.version}-slr-arm64.tar.xz";
          hash = "sha256-5ZtkbnPeSvIf8vbHlbKOe2yIkhSzxtr45lpWY0zQbDc=";
        };
      };
    };
  };

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components.

      (This package is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

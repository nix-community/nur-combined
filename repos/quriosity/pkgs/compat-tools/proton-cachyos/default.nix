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

stdenvNoCC.mkDerivation (finalAttrs: let
  releaseVersion = lib.removePrefix "cachyos-" (lib.removeSuffix "-slr" finalAttrs.version);
in {
  pname = "proton-cachyos";
  version = "cachyos-11.0-20261015-slr";

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
        toolName = "proton-cachyos-${releaseVersion}-slr-x86_64";
        src = fetchzip {
          url = "https://github.com/CachyOS/proton-cachyos/releases/download/${finalAttrs.version}/proton-cachyos-${releaseVersion}-slr-x86_64.tar.xz";
          hash = "sha256-Vb1AvDQLIpgxr3ABPMstM3DFRN1tfUD+6OnhQirMnAQ=";
        };
      };
      "x86_64-v3" = {
        toolName = "proton-cachyos-${releaseVersion}-slr-x86_64_v3";
        src = fetchzip {
          url = "https://github.com/CachyOS/proton-cachyos/releases/download/${finalAttrs.version}/proton-cachyos-${releaseVersion}-slr-x86_64_v3.tar.xz";
          hash = "sha256-USZ7wVV069xmGJdtyg6b/pdv7qqLkUkSZEyHiiVIs1o=";
        };
      };
      "aarch64" = {
        toolName = "proton-cachyos-${releaseVersion}-slr-arm64";
        src = fetchzip {
          url = "https://github.com/CachyOS/proton-cachyos/releases/download/${finalAttrs.version}/proton-cachyos-${releaseVersion}-slr-arm64.tar.xz";
          hash = "sha256-xV683d43wjkDyERXknf4yDzQbWVlD3w+Wo4H6AxeIis=";
        };
      };
    };

    updateScript = writeScript "update-proton-cachyos" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      repo="https://api.github.com/repos/CachyOS/proton-cachyos/releases"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output)"
      for variant in x86_64 x86_64-v3 aarch64; do
        update-source-version proton-cachyos "$version" --ignore-same-version --source-key="variants.$variant.src"
      done
    '';
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

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
  version = "11.0-20261024";

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
          hash = "sha256-A6tVDll8DN2lJJKhhiBAF5MSsjxFgm1z4CXrHXOQgVs=";
        } // {
          tag = "refs/tags/wineland-${finalAttrs.version}";
        };
      };
      "x86_64-v3" = {
        toolName = "proton-wineland-${finalAttrs.version}-x86_64_v3";
        src = fetchzip {
          url = "https://github.com/nanomatters/proton-salkim/releases/download/wineland-${finalAttrs.version}/proton-wineland-${finalAttrs.version}-x86_64_v3.tar.xz";
          hash = "sha256-Q/HzmHBZplWg/1JMvkxgxNXkDMsG0U3QjCRSisV2Qu0=";
        } // {
          tag = "refs/tags/wineland-${finalAttrs.version}";
        };
      };
    };

    updateScript = writeScript "update-proton-wineland" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      repo="https://api.github.com/repos/nanomatters/proton-salkim/releases"
      version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false and (.tag_name | startswith("wineland-")))) | .[0].tag_name' --raw-output)"
      version="''${version#wineland-}"
      for variant in x86_64 x86_64-v3; do
        update-source-version proton-wineland "$version" --ignore-same-version --source-key="variants.$variant.src"
      done
    '';
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

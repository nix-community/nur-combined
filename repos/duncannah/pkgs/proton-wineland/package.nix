{
  fetchzip,
  lib,
  stdenvNoCC,
  writeScript,
  steamDisplayName ? null,
}:
assert
  steamDisplayName == null
  || throw "proton-wineland: The `steamDisplayName` interface has been changed to an attribute, which is overridable using `overrideAttrs`.";

stdenvNoCC.mkDerivation (finalAttrs: {
  # Can be overridden to alter the display name in Steam.
  # This is useful when multiple versions are installed together.
  steamDisplayName = "Proton-Wineland";

  pname = "proton-wineland";
  version = "11.0-20261005";

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

    # Make it impossible to add to an environment. Use the NixOS option instead.
    # Also leave some breadcrumbs in the file.
    echo "${finalAttrs.pname} must not be installed into environments. Use programs.steam.extraCompatPackages instead." > $out

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
    variants."x86_64-linux" = {
      toolName = "${finalAttrs.pname}-${finalAttrs.version}-x86_64";
      src = fetchzip {
        url = "https://github.com/nanomatters/proton-cachyos/releases/download/wineland-${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}-x86_64.tar.xz";
        hash = "sha256-GTfrrIoNEesyXB5ZsQd/DEOw4VvZG+/9g4Uldq+RDzs=";
      };
    };

    updateScript = writeScript "update-proton-wineland" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl jq common-updater-scripts
      set -euo pipefail
      repo="https://api.github.com/repos/nanomatters/proton-cachyos/releases"
      version="$(curl --fail --silent --show-error --location "$repo" | jq --exit-status --raw-output '
        [.[] | select(.prerelease == false and (.tag_name | startswith("wineland-")))]
        | .[0].tag_name | strings | sub("^wineland-"; "") | select(length > 0)
      ')"
      update-source-version proton-wineland "$version" --source-key="variants.x86_64-linux.src"
    '';
  };

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine with Wayland improvements.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/nanomatters/proton-cachyos";
    license = lib.licenses.bsd3;
    broken = !(stdenvNoCC.hostPlatform.isLinux && stdenvNoCC.hostPlatform.isx86_64);
    platforms = builtins.attrNames finalAttrs.passthru.variants;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})

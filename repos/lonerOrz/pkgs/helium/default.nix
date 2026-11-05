{
  lib,
  fetchurl,
  appimageTools,
  stdenv,
  callPackage,
  ...
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "helium";
  version = current.version;

  versionFile = "pkgs/helium/version.json";

  # Map Nix system names to upstream asset architecture names.
  assetArch = {
    x86_64-linux = "x86_64";
    aarch64-linux = "arm64";
  };

  releaseBase = "https://github.com/imputnet/helium-linux/releases/download";

  # Generate the upstream AppImage URL.
  urlFor =
    version: system:
    let
      arch = assetArch.${system} or (throw "helium: unsupported system: ${system}");
    in
    "${releaseBase}/${version}/helium-${version}-${arch}.AppImage";

  # Generate URL templates for all supported systems.
  hashUrls = lib.mapAttrs (system: _: urlFor "@VERSION@" system) assetArch;

  # Fetch the latest upstream GitHub Release version.
  templateCommands = {
    VERSION = ''
      ${
        (callPackage ../../utils/fetcher.nix { }).githubRelease {
          owner = "imputnet";
          repo = "helium-linux";
        }
      } | jq -er '.version'
    '';
  };

  # Prepare source derivations for every supported architecture.
  sourceMap = lib.mapAttrs (
    system: _:
    fetchurl {
      url = urlFor version system;
      hash = current.${system + "-hash"};
    }
  ) assetArch;
in
appimageTools.wrapType2 (finalAttrs: {
  inherit pname version;

  src =
    sourceMap.${stdenv.hostPlatform.system}
      or (throw "helium: unsupported system: ${stdenv.hostPlatform.system}");

  extraInstallCommands = ''
    mkdir -p $out/share/{applications,lib/helium}

    cp -r ${finalAttrs.contents}/opt/${finalAttrs.pname}/locales \
      "$out/share/lib/helium"

    cp -r ${finalAttrs.contents}/usr/share/* "$out/share"

    cp "${finalAttrs.contents}/${finalAttrs.pname}.desktop" \
      "$out/share/applications/"
  '';

  passthru.updateScript = callPackage ../../utils/update.nix {
    inherit pname versionFile;

    updateMethod = "none";

    fetchMetaCommand = lib.getExe (
      callPackage ../../utils/fetch-urls.nix {
        inherit versionFile templateCommands hashUrls;
      }
    );
  };

  meta = {
    description = "Private, fast, and honest web browser based on Chromium";
    homepage = "https://github.com/imputnet/helium-chromium";
    changelog = "https://github.com/imputnet/helium-linux/releases/tag/${version}";
    platforms = builtins.attrNames assetArch;
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "helium";
  };
})

{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  callPackage,
}:

let
  current = lib.trivial.importJSON ./version.json;

  pname = "crabport";
  version = current.version;

  versionFile = "pkgs/crabport/version.json";

  # Map Nix system names to upstream asset architecture names.
  assetArch = {
    x86_64-linux = "x86_64";
    aarch64-linux = "aarch64";
  };

  releaseBase = "https://github.com/chi11321/CrabPort/releases/download";

  # Generate the upstream AppImage URL.
  urlFor =
    version: system:
    let
      arch = assetArch.${system} or (throw "crabport: unsupported system: ${system}");
    in
    "${releaseBase}/v${version}/CrabPort-v${version}-linux-${arch}.AppImage";

  # Generate URL templates for all supported systems.
  hashUrls = lib.mapAttrs (system: _: urlFor "@VERSION@" system) assetArch;

  # Fetch the latest upstream GitHub Release version.
  templateCommands = {
    VERSION = ''
      ${
        (callPackage ../../utils/fetcher.nix { }).githubRelease {
          owner = "chi11321";
          repo = "CrabPort";
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

  system = stdenv.hostPlatform.system;
in
appimageTools.wrapType2 (finalAttrs: {
  inherit pname version;

  src = sourceMap.${system} or (throw "crabport: unsupported system: ${system}");

  extraInstallCommands = ''
    install -Dm644 \
      ${finalAttrs.contents}/CrabPort.desktop \
      $out/share/applications/CrabPort.desktop

    cp -r ${finalAttrs.contents}/usr/share/icons $out/share/
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
    description = "Modern, cross-platform SSH / SFTP client built with Rust and GPUI";
    homepage = "https://github.com/chi11321/CrabPort";
    license = lib.licenses.asl20;
    platforms = builtins.attrNames assetArch;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = finalAttrs.pname;
  };
})

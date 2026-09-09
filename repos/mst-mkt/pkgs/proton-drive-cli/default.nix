{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  glib,
  libsecret,
  versionCheckHook,
  writeShellScript,
  curl,
  jq,
}:

let
  platforms = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    aarch64-darwin = "darwin-arm64";
  };
  platform = platforms.${stdenvNoCC.hostPlatform.system};
  sources = lib.importJSON ./sources.json;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-drive-cli";
  inherit (sources) version;

  src = fetchurl {
    url = "https://proton.me/download/drive/cli/${finalAttrs.version}/${platform}/proton-drive";
    sha512 = sources.hashes.${platform};
  };

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/proton-drive

    runHook postInstall
  '';

  postFixup = lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
    wrapProgram $out/bin/proton-drive \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          glib
          libsecret
        ]
      }
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";

  passthru.updateScript = writeShellScript "update-proton-drive-cli" ''
    set -euo pipefail

    ${lib.getExe curl} -fsSL https://proton.me/download/drive/cli/version.json \
      | ${lib.getExe jq} --argjson platforms ${lib.escapeShellArg (builtins.toJSON (builtins.attrValues platforms))} '
          [.Releases[] | select(.CategoryName == "Stable")]
          | max_by(.Version | split(".") | map(tonumber))
          | {
              version: .Version,
              hashes: (
                [.Files[] | { key: (.Url | split("/")[-2]), value: .Sha512CheckSum }]
                | from_entries
                | with_entries(select(.key | IN($platforms[])))
              )
            }
        ' \
      > pkgs/proton-drive-cli/sources.json
  '';

  meta = {
    description = "Command-line interface for Proton Drive";
    homepage = "https://github.com/ProtonDriveApps/sdk/tree/main/cli";
    changelog = "https://github.com/ProtonDriveApps/sdk/blob/cli/v${finalAttrs.version}/cli/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames platforms;
    mainProgram = "proton-drive";
  };
})

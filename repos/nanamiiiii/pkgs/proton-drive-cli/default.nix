{
  lib,
  stdenvNoCC,
  fetchurl,
  writeShellScript,
  curl,
  gnugrep,
  gnused,
  common-updater-scripts,
  autoPatchelfHook,
  glib,
  libffi,
  libgcrypt,
  libgpg-error,
  libsecret,
  libselinux,
  makeWrapper,
  pcre2,
  util-linux,
  writableTmpDirAsHomeHook,
  xdg-utils,
}:
let
  secretsLibs = [
    libsecret
    glib
    pcre2
    libffi
    libselinux
    libgpg-error
    util-linux.lib
    libgcrypt.lib
  ];

  version = "0.6.0";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/linux-x64/proton-drive";
      hash = "sha512-539bJ6UagQY8I8FawKnwfg7FyGjnhnDzS0Wzw8Lmee12nmIleWuQDQ0Cc1oMUqIeunI1bzrWF94HbEBVMuaY3A==";
    };
    aarch64-linux = fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/linux-arm64/proton-drive";
      hash = "sha512-RlHXsj0RGpQNWg0wimKq99OfDWqM66TG+qK81pYkVX4OsZ9aUo6NdZ+x/NlsnglHd/q90hg3Le5WPGcSvRPN3g==";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "proton-drive-cli: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-drive-cli";
  inherit version;

  src = source;

  dontUnpack = true;

  strictDeps = true;
  __structuredAttrs = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = secretsLibs;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/proton-drive
    wrapProgram $out/bin/proton-drive \
      --suffix LD_LIBRARY_PATH : "${lib.makeLibraryPath secretsLibs}" \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}

    runHook postInstall
  '';

  dontStrip = true;

  passthru = {
    inherit sources;
    updateScript = writeShellScript "update-proton-drive-cli" ''
      set -o errexit -o nounset -o pipefail
      export PATH="${
        lib.makeBinPath [
          curl
          gnugrep
          gnused
          common-updater-scripts
        ]
      }"

      newVersion="$(${curl}/bin/curl --fail --silent https://proton.me/download/drive/cli/index.html \
        | grep --only-matching --extended-regexp '/download/drive/cli/[0-9]+(\.[0-9]+)+/linux-x64/proton-drive' \
        | sed --quiet '1s|.*/cli/\([^/]*\)/.*|\1|p')"

      if [[ -z "$newVersion" ]]; then
        echo "Failed to determine the latest Proton Drive CLI version" >&2
        exit 1
      fi
      if [[ "${version}" = "$newVersion" ]]; then
        echo "proton-drive-cli is already up-to-date at ${version}"
        exit 0
      fi

      for platform in ${lib.escapeShellArgs (builtins.attrNames sources)}; do
        update-source-version proton-drive-cli "$newVersion" \
          --ignore-same-version \
          --source-key="sources.$platform"
      done
    '';
  };

  nativeInstallCheckInputs = [ writableTmpDirAsHomeHook ];
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # installCheck runs without a Secret Service backend in the Nix sandbox.
    export PROTON_DRIVE_CREDENTIALS_STORE=unsafe_file
    export PROTON_DRIVE_CACHE_DIR="$TMPDIR/proton-drive-cli"
    $out/bin/proton-drive version | grep -F "cli-drive@${finalAttrs.version}"
    $out/bin/proton-drive help > /dev/null

    runHook postInstallCheck
  '';

  meta = {
    description = "Command-line interface for Proton Drive";
    homepage = "https://proton.me/download/drive/cli/index.html";
    license = lib.licenses.mit;
    mainProgram = "proton-drive";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})

{
  lib,
  stdenvNoCC,
  fetchurl,
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

  # Published binaries and their SHA-512 checksums, per
  # https://proton.me/download/drive/cli/index.html (release 2026-06-17).
  sources = {
    x86_64-linux = {
      url = "https://proton.me/download/drive/cli/0.4.6/linux-x64/proton-drive";
      hash = "sha512-0YdAmTJ0Lm/caq4plZmPTInqUZmSgzlbyNC9xTQ6edMb9aSF1a+a3zt5CfyS8tLvCxM+3Ek51frx0JbrdEQluw==";
    };
    aarch64-linux = {
      url = "https://proton.me/download/drive/cli/0.4.6/linux-arm64/proton-drive";
      hash = "sha512-krSMy4L2SAdZq6ECFUarSHwrrvk8mFov02LVpXZpMyaM0DnFRnhu/GQbXCzbYAwSEeHZLzQwWWdrhGG7IdRxFw==";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "proton-drive-cli: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-drive-cli";
  version = "0.4.6";

  src = fetchurl {
    inherit (source) url hash;
  };

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

  nativeInstallCheckInputs = [ writableTmpDirAsHomeHook ];
  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    # installCheck runs without a Secret Service backend in the Nix sandbox.
    PROTON_DRIVE_UNSAFE_SECRETS=1 $out/bin/proton-drive version | grep -F "cli-drive@${finalAttrs.version}"
    PROTON_DRIVE_UNSAFE_SECRETS=1 $out/bin/proton-drive help > /dev/null

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

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libsecret,
}:

let
  pname = "proton-drive-cli";
  sources = lib.importJSON ./sources.json;

  platforms = {
    x86_64-linux = "linux-x64";
    aarch64-linux = "linux-arm64";
    x86_64-darwin = "darwin-x64";
    aarch64-darwin = "darwin-arm64";
  };

  platform =
    platforms.${stdenv.hostPlatform.system} or (throw "${pname}: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  inherit pname;
  inherit (sources) version;

  src = fetchurl {
    url = "https://proton.me/download/drive/cli/${sources.version}/${platform}/proton-drive";
    sha512 = sources.hashes.${platform};
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Bun single-file executables carry the JS bundle after the ELF/Mach-O
  # payload; stripping truncates it.
  dontStrip = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  # The default "keychain" credential store goes through Bun.secrets, which
  # dlopens libsecret-1.so.0 at runtime instead of linking it.
  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [ libsecret ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/proton-drive
    runHook postInstall
  '';

  meta = {
    description = "Official Proton Drive command-line interface";
    homepage = "https://github.com/ProtonDriveApps/sdk/tree/main/cli";
    changelog = "https://github.com/ProtonDriveApps/sdk/blob/main/cli/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = builtins.attrNames platforms;
    mainProgram = "proton-drive";
  };
}

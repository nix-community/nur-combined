{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libsecret,
  glib,
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

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/proton-drive
    runHook postInstall
  '';

  # The default "keychain" credential store goes through Bun.secrets, which
  # dlopens libsecret-1.so.0 and libglib-2.0.so.0 directly at runtime instead
  # of linking them. A RUNPATH of 2+ colon-separated entries (or one long
  # enough entry) corrupts this binary -- autoPatchelfHook's patchelf rewrite
  # then segfaults inside ld.so (reproduced; verified safe up to ~70 chars).
  # LD_LIBRARY_PATH via a wrapper avoids touching the binary at all.
  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/proton-drive \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libsecret glib.out ]}"
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

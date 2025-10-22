{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc,
}:

let
  # Upstream version tag. Override to update.
  version = "2025.10.21-224d294";

  # Map platform to upstream's OS/ARCH path segments.
  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "cursor-agent: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if lib.hasPrefix "x86_64" stdenv.hostPlatform.system then
      "x64"
    else if
      lib.hasPrefix "aarch64" stdenv.hostPlatform.system
      || lib.hasPrefix "arm64" stdenv.hostPlatform.system
    then
      "arm64"
    else
      throw "cursor-agent: unsupported arch ${stdenv.hostPlatform.system}";

  sha256BySystem = {
    "x86_64-linux" = "sha256-p3Dgm/Q1z8iAu9Zjvfo4N7iPynMI1L3MXzx7JkbnITY=";
    "aarch64-linux" = "sha256-G/WU2oeHD0DiFrl510Syz+WJX9nhi1xuJz/xb1yPgzM=";
    "x86_64-darwin" = "sha256-53TxL5Sg8UEAc1yQp48kmA4LVW4H7LylMtxwF3SaRo0=";
    "aarch64-darwin" = "sha256-TKXCtLsFFwwVlx8DVydNkkJK0DDLKV1kN4+3oUT9qwU=";
  };

  srcUrl = "https://downloads.cursor.com/lab/${version}/${os}/${arch}/agent-cli-package.tar.gz";
  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "cursor-agent: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "cursor-agent";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    sha256 = srcHash;
  };

  # The tarball contains a top-level directory named "dist-package".
  sourceRoot = "dist-package";

  # This package is prebuilt and self-contained (bundles its own node, rg, sqlite3 binding, etc.)
  dontBuild = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gcc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/cursor-agent"
    cp -a ./* "$out/lib/cursor-agent/"

    # Ensure main launcher is executable
    chmod +x "$out/lib/cursor-agent/cursor-agent"

    mkdir -p "$out/bin"
    ln -s "$out/lib/cursor-agent/cursor-agent" "$out/bin/cursor-agent"

    runHook postInstall
  '';

  # No tests provided upstream; the bundle is opaque
  doCheck = false;

  meta = with lib; {
    description = "Cursor AI Agent CLI";
    longDescription = ''
      The Cursor Agent CLI is a command-line interface from Cursor.
      It provides a simple way to interact with AI Agents from the command line.
    '';
    homepage = "https://cursor.com";
    license = licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "cursor-agent";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}

{
  lib,
  stdenv,
  fetchurl,
}:

let
  # Upstream version tag. Override to update.
  version = "2025.09.04-fc40cd1";

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
    "x86_64-linux" = "sha256-Y1ynrrHfhbmMKkbZ1C3Xl+uZy3AWnmAXwTC+OkMcquc=";
    "aarch64-linux" = "sha256-EeeHCWFDCayFGpSKkeHxZe2JSHsQ+hJYAwepTm6i8Bo=";
    "x86_64-darwin" = "sha256-yzu0Ea5/X38RGyaFx0VR1O2aXzWs/XHopDyQzouFXP8=";
    "aarch64-darwin" = "sha256-C2av4foh8XcXi+CYzFEz6jeFIR7sTjZFi1fk2s0I46I=";
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

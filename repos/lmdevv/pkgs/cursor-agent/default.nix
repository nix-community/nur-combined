{
  lib,
  stdenv,
  fetchurl,
}:

let
  # Upstream version tag. Override to update.
  version = "2025.09.12-4852336";

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
    "x86_64-linux" = "sha256-tUy4sxaDsPL2aIMjd3W/1aAj2uL04He90sQ0k3YxRtE=";
    "aarch64-linux" = "sha256-zWIg5lrwVGpmO8jW0vglo8r9wmCvxyfvgWv6LO8P9mg=";
    "x86_64-darwin" = "sha256-iP3RNgy5qQeGd9STWI/eN8p2MKG3ZGdQ/NUsQn/oUrk=";
    "aarch64-darwin" = "sha256-jv2g4zKhcWGJc/0/LSYoXiXHjJqimaaPw24x73o0m6M=";
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

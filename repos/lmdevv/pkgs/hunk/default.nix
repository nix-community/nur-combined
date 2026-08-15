{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  gcc,
}:

let
  version = "0.18.2";

  os =
    if stdenv.hostPlatform.isLinux then
      "linux"
    else if stdenv.hostPlatform.isDarwin then
      "darwin"
    else
      throw "hunk: unsupported OS ${stdenv.hostPlatform.system}";

  arch =
    if lib.hasPrefix "x86_64" stdenv.hostPlatform.system then
      "x64"
    else if
      lib.hasPrefix "aarch64" stdenv.hostPlatform.system
      || lib.hasPrefix "arm64" stdenv.hostPlatform.system
    then
      "arm64"
    else
      throw "hunk: unsupported arch ${stdenv.hostPlatform.system}";

  sha256BySystem = {
    "x86_64-linux" = "sha256-a3KOOZtZ52ybfxtza8nTGphCXFYIjjFiRcoCXjsNKx0=";
    "aarch64-linux" = "sha256-UqNP5V8ORCOwlIcpFeJIcjLPt1Qd5agNzBIoMMhQVuU=";
    "x86_64-darwin" = "sha256-3/4BUsNk+1mnpnX1d29IOZIC8klXh6Wst6kKAH4bCPA=";
    "aarch64-darwin" = "sha256-6CX008IQFt5cdWoTK2ttZrAqFt3xP1PhX8dY+9zToFI=";
  };

  srcUrl = "https://github.com/modem-dev/hunk/releases/download/v${version}/hunkdiff-${os}-${arch}.tar.gz";
  srcHash =
    sha256BySystem.${stdenv.hostPlatform.system}
      or (throw "hunk: missing sha256 for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "hunk";
  inherit version;

  src = fetchurl {
    url = srcUrl;
    sha256 = srcHash;
  };

  sourceRoot = "hunkdiff-${os}-${arch}";

  dontBuild = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    gcc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    install -Dm755 hunk "$out/bin/hunk"

    runHook postInstall
  '';

  doCheck = false;

  meta = with lib; {
    description = "Review-first terminal diff viewer for agentic coders";
    longDescription = ''
      Hunk is a review-first terminal diff viewer for agent-authored
      changesets, built on OpenTUI and Pierre diffs. It provides
      multi-file review stream with sidebar navigation, inline AI and
      agent annotations, split/stack/responsive auto layouts, watch
      mode, and keyboard/mouse/pager/Git difftool support.
    '';
    homepage = "https://github.com/modem-dev/hunk";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "hunk";
    maintainers = [ "lmdevv" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
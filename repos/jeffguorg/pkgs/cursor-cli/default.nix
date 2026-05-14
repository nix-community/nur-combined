{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeBinaryWrapper
, sources
, zlib
}:
let
  os = if stdenv.hostPlatform.isDarwin then
    "darwin"
  else if stdenv.hostPlatform.isLinux then
    "linux"
  else
    throw "Unsupported OS: ${stdenv.hostPlatform.system}";

  arch = if stdenv.hostPlatform.isAarch64 then
    "arm64"
  else if stdenv.hostPlatform.isx86_64 then
    "amd64"
  else
    throw "Unsupported architecture: ${stdenv.hostPlatform.system}";

  cursor-cli-bin = sources."cursor-cli-bin-${arch}-${os}";
in stdenv.mkDerivation rec {
  pname = "cursor-cli-bin";
  version = cursor-cli-bin.version;

  src = cursor-cli-bin.src;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    zlib
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/cursor-agent $out/bin
    tar --strip-components=1 -xzf $src -C $out/lib/cursor-agent
    ln -s $out/lib/cursor-agent/cursor-agent $out/bin/cursor-agent

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cursor Agent CLI binary release";
    homepage = "https://cursor.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "cursor-agent";
  };
}

{ lib
, stdenv
, sources
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

  kagent-bin = sources."kagent-bin-${arch}-${os}";
in
stdenv.mkDerivation rec {
  pname = "kagent-bin";
  version = kagent-bin.version;

  src = kagent-bin.src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/kagent

    runHook postInstall
  '';

  meta = with lib; {
    description = "kagent binary release";
    homepage = "https://github.com/kagent-dev/kagent";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "kagent";
  };
}

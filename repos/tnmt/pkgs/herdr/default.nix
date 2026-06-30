{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.7.1";

  sources = {
    "x86_64-linux" = {
      asset = "herdr-linux-x86_64";
      hash = "sha256-uWWsr/wsIvVLbmxkr3z46Yo/SsJiJjCgWZxnpLnYplQ=";
    };
    "aarch64-linux" = {
      asset = "herdr-linux-aarch64";
      hash = "sha256-ly1ips1U0BYtLegNuY2uQVt3L1WCL09fb4wy0BZLKbk=";
    };
    "x86_64-darwin" = {
      asset = "herdr-macos-x86_64";
      hash = "sha256-5yMqu9BWiHuv4Pa4Hlj1njPK/XrGCeO8w1S44A77Bjc=";
    };
    "aarch64-darwin" = {
      asset = "herdr-macos-aarch64";
      hash = "sha256-hKp/OMg1tOtao4wpZggTAjzyMXjkZUHEucJgcS/lLVE=";
    };
  };

  source = sources.${stdenv.hostPlatform.system} or (throw "herdr: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "herdr";
  inherit version;

  src = fetchurl {
    url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/herdr"
    runHook postInstall
  '';

  meta = {
    description = "Terminal workspace manager for AI coding agents";
    homepage = "https://herdr.dev";
    license = lib.licenses.agpl3Plus;
    mainProgram = "herdr";
    platforms = lib.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
  };
}

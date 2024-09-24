{ stdenv
, fetchurl
, autoPatchelfHook
, lib
, ...
}:
stdenv.mkDerivation rec {
  pname = "naiveproxy";
  version = "128.0.6613.40-1";
  preferLocalBuild = true;

  src = fetchurl {
    aarch64-linux = {
      url = "https://github.com/klzgrad/naiveproxy/releases/download/v${version}/naiveproxy-v${version}-linux-arm64.tar.xz";
      hash = "sha256-xs2VH5DWR0Q0JphFNL/dthaWk6gnHY5Iw0TDEDyA3LY=";
    };
    x86_64-linux = {
      url = "https://github.com/klzgrad/naiveproxy/releases/download/v${version}/naiveproxy-v${version}-linux-x64.tar.xz";
      hash = "sha256-wvORRJ3fepQpjX35Ks3U/8jBJhSqsGLyUDauzClUmYU=";
    };
  }.${stdenv.system} or (throw "naiveproxy-bin: ${stdenv.system} is unsupported.");

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.libgcc ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 naive $out/bin/naiveproxy

    mkdir -p $out/share/doc/naiveproxy
    install -Dm644 USAGE.txt $out/share/doc/naiveproxy/USAGE.txt
    
    mkdir -p $out/share/licenses/naiveproxy
    install -Dm644 LICENSE $out/share/licenses/naiveproxy/LICENSE

    runHook postInstall
  '';

  meta = {
    description = "Make a fortune quietly";
    homepage = "https://github.com/klzgrad/naiveproxy";
    downloadPage = "https://github.com/klzgrad/naiveproxy/releases";
    changelog = "https://github.com/klzgrad/naiveproxy/releases/tag/v${version}";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.bsd3;
    mainProgram = "naiveproxy";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
  };
}

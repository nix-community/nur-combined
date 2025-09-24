{
  stdenv,
  fetchurl,
  autoPatchelfHook,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "naiveproxy";
  version = "140.0.7339.123-1";
  preferLocalBuild = true;

  src = fetchurl {
    url = "https://github.com/klzgrad/naiveproxy/releases/download/v${version}/naiveproxy-v${version}-linux-x64.tar.xz";
    hash = "sha256-MqrBW3/v+t27/1DHNBzBzCOjW5I6d/F0w+ugcLh3wK0=";
  };

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
    changelog = "https://github.com/klzgrad/naiveproxy/releases/tag/v${version}";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.bsd3;
    mainProgram = "naiveproxy";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = [ "x86_64-linux" ];
  };
}

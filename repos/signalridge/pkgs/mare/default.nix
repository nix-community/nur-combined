{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "1.0.2";
  sources = {
    x86_64-linux = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.2/mare-v1.0.2-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "93499a09574289057e1256b328440b4b149ba7ac4869b2657f52f2b17245fe26";
      dir = "mare-v1.0.2-x86_64-unknown-linux-gnu";
    };
    aarch64-linux = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.2/mare-v1.0.2-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "bb93c44e36dddeeac207eea4ab16cd421c3e1bc153317de59b55b829e035bd78";
      dir = "mare-v1.0.2-aarch64-unknown-linux-gnu";
    };
    x86_64-darwin = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.2/mare-v1.0.2-x86_64-apple-darwin.tar.gz";
      sha256 = "59c77650244a4b90446aaddec8698aad11aa4846169813d812414db5dc5aec03";
      dir = "mare-v1.0.2-x86_64-apple-darwin";
    };
    aarch64-darwin = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.2/mare-v1.0.2-aarch64-apple-darwin.tar.gz";
      sha256 = "904ddd3083fe13e060dfc7ea8411d19b9a026b477b93683142f8794eb2af3cdb";
      dir = "mare-v1.0.2-aarch64-apple-darwin";
    };
  };
  srcInfo = sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "mare";
  inherit version;

  src = fetchurl {
    inherit (srcInfo) url sha256;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  sourceRoot = srcInfo.dir;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 mare "$out/bin/mare"
    install -Dm644 LICENSE "$out/share/licenses/mare/LICENSE"
    install -Dm644 README.md "$out/share/doc/mare/README.md"
    mkdir -p "$out/share/mare"
    cp -r types "$out/share/mare/types"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Hyperextensible AI coding agent harness (Rust core, Lua 5.5 plugins)";
    homepage = "https://github.com/signalridge/mare";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = builtins.attrNames sources;
    mainProgram = "mare";
  };
}

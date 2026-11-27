{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "1.0.0";
  sources = {
    x86_64-linux = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.0/mare-v1.0.0-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "94ef6a1fb3319ad435262c01002e0e14483f24181b014c6e2729e2580f2bfe9a";
      dir = "mare-v1.0.0-x86_64-unknown-linux-gnu";
    };
    aarch64-linux = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.0/mare-v1.0.0-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "3f046f68f3ea0c03cca7c4f45948b272e63785d9e37881abb6f2ca22fdf45443";
      dir = "mare-v1.0.0-aarch64-unknown-linux-gnu";
    };
    x86_64-darwin = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.0/mare-v1.0.0-x86_64-apple-darwin.tar.gz";
      sha256 = "8dc3365949ce6519e64c15f7e0191478d42f673eba66cdf07922560100f72a19";
      dir = "mare-v1.0.0-x86_64-apple-darwin";
    };
    aarch64-darwin = {
      url = "https://github.com/signalridge/mare/releases/download/v1.0.0/mare-v1.0.0-aarch64-apple-darwin.tar.gz";
      sha256 = "51e62946237511ab63aa387be5c821b727a7549a3b13517244b320b6bd8907a7";
      dir = "mare-v1.0.0-aarch64-apple-darwin";
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
    install -Dm644 THIRD_PARTY_NOTICES.md "$out/share/licenses/mare/THIRD_PARTY_NOTICES.md"
    install -Dm644 licenses/cordis-LICENSE "$out/share/licenses/mare/cordis-LICENSE"
    install -Dm644 licenses/RUST-THIRD-PARTY-NOTICES.txt "$out/share/licenses/mare/RUST-THIRD-PARTY-NOTICES.txt"
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

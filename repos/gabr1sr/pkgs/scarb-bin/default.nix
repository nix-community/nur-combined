{
  lib,
  stdenv,
  fetchzip,
  git,
  pkg-config,
  openssl,
  makeWrapper,
  installShellFiles,
  autoPatchelfHook
}:
let
  version = "2.6.4";
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "05x135vj2lkwwg1gg7fbg8hw1qv1r0gm9m572kdvfqkmxpikchd0";
    };

    "aarch64-linux" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "1zxndgrhxgzijy3p2ff9p83dmx50539nsh8fk4jrs5yfa0b587x9";
    };

    "x86_64-darwin" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "1rxyy0k62dhygbpc0rvnrmd8jkpggms0sp7lp7l7v1bwzc7vv7wg";
    };

    "aarch64-darwin" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "1xhl0fp7kiw3kmgdwsgy4lm1fpk5svx40cdc8id2qrqk8a2ijkq0";
    };
  };
  
  bins = [
    "scarb"
    "scarb-cairo-language-server"
    "scarb-cairo-run"
    "scarb-cairo-test"
    "scarb-snforge-test-collector"
  ];

  arch = stdenv.hostPlatform.system;
  source = sources.${arch};
in
stdenv.mkDerivation {
  pname = "scarb-bin";
  version = version;

  src = fetchzip {
    inherit (source) url sha256;
  };

  nativeBuildInputs = [
    pkg-config
    openssl
    makeWrapper
    installShellFiles
  ] ++ lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  installPhase =
    let
      path = lib.makeBinPath [ git ];
    in ''
      set -e
      mkdir -p $out/bin
      ${lib.concatMapStringsSep "\n" (bin: ''
      install -m755 -D ./bin/${bin} $out/bin/${bin}
      wrapProgram $out/bin/${bin} --prefix PATH : "${path}"
      '') bins}
    '';

  preFixup = lib.optionalString (stdenv?cc.cc.libgcc) ''
    set -x
    addAutoPatchelfSearchPath ${stdenv.cc.cc.libgcc}/lib
  '';

  installCheckPhase = ''
    $out/bin/scarb --version > /dev/null
    $out/bin/scarb-cairo-run --version > /dev/null
    $out/bin/scarb-cairo-test --version > /dev/null
    $out/bin/scarb-snforge-test-collector --version > /dev/null
  '';

  doInstallCheck = true;

  meta = {
    description = "The Cairo package manager";
    homepage = "https://github.com/software-mansion/scarb";

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    
    license = lib.licenses.mit;
  };
}

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
  version = "2.6.5";
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "1gmr67fgplpqkpr09dxqa1qy1hql7s6zxk85harcacb7pywky08x";
    };

    "aarch64-linux" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "19d7nc720727hpl4gl45svar7h6cy0s05008yb9204vlzxv34y3q";
    };

    "x86_64-darwin" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "0mjnk911mj48rf8gbx41pxsk214wpmji4kx56iaacg62vlvzx0xx";
    };

    "aarch64-darwin" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v${version}/scarb-v${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "08hh09y0vh4xc3hj32709lk0irjqvhbgp6z3cq56qz53prkz9zy3";
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

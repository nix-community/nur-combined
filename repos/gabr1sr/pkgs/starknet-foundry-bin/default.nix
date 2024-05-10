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
  version = "0.22.0";
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "06l4p48l33lsllba6x23sbkm06yrwddv6fgv0r5j73x69qcaj9ic";
    };

    "aarch64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "1vasa3fsc6mw070vwpi68w5sj7g3d8kz7j7lic8ml0p0hmk25sj6";
    };

    "x86_64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "053gi76y97k1b8bny4k7sr511gp007y0bb1b6wlcr6r6ndzjv5xv";
    };

    "aarch64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "1x7247idwpxq3i1a19mqaw4mhq4084fdgmxnp2cijj9irbyj3cbl";
    };
  };

  bins = [
    "snforge"
    "sncast"
  ];

  arch = stdenv.hostPlatform.system;
  source = sources.${arch};
in
stdenv.mkDerivation {
  pname = "starknet-foundry-bin";
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
  $out/bin/snforge --version > /dev/null
  $out/bin/sncast --version > /dev/null
  '';

  doInstallCheck = true;

  meta = {
    description = "Blazing fast toolkit for developing Starknet contracts.";
    homepage = "https://github.com/foundry-rs/starknet-foundry";

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    
    license = lib.licenses.mit;
  };
}

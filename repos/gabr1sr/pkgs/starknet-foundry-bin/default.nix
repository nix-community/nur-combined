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
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v0.14.0/starknet-foundry-v0.14.0-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "0yrw9mg4hmn9zpw6v4rxl6s18gsdhpd7zk5qwc6xxrg642g93vg8";
    };

    "aarch64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v0.14.0/starknet-foundry-v0.14.0-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "0089s0gw05n4vipb7srly4wsakilagrf7p94clkl1w38ykdbdln0";
    };

    "x86_64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v0.14.0/starknet-foundry-v0.14.0-x86_64-apple-darwin.tar.gz";
      sha256 = "0dv3pn8r4v47a7r1v0h69ydd0ypb0dngbzbdfnkflwr3fv4h73vd";
    };

    "aarch64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v0.14.0/starknet-foundry-v0.14.0-aarch64-apple-darwin.tar.gz";
      sha256 = "0q0algnfxjvw9s3a2bbbwr9z6pnjp2jik9y6v20169dd4cps6lyy";
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
  version = "0.14.0";

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

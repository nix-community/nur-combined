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
  version = "0.24.0";
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "0172b8lxcjik5frwsh521pw0ra9qva96fmvzgpmi6p8wj6aqbw2r";
    };

    "aarch64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "02bgcqx5d85xc533jdvsvzhzfxnifq78x1hlk5ajmgdzwbacskvk";
    };

    "x86_64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "0wmhmrs552jrmxbfk7nq2pv32rll6pq0jxr7zli0aqb10l01jyhq";
    };

    "aarch64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "14sicjkl3d4vj31rvkvb4qp0807021v1yk82z4jscjq3smj56i90";
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

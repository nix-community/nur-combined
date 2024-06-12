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
  version = "0.25.0";
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "1h0l5gvmf80mlzpz9nsd3wqil5ghysbqmb3xzxdwjgi8xibjfqh3";
    };

    "aarch64-linux" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "066mzmk3vpv4dbdsnlmswazmbrp2b58j2gb1v2v7k8cj6vcxfm7y";
    };

    "x86_64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-x86_64-apple-darwin.tar.gz";
      sha256 = "11w5d6i8lh4pv5hy4l6k3q4am6yqc20sbwzjcm9f3dc8rw06q680";
    };

    "aarch64-darwin" = {
      url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v${version}/starknet-foundry-v${version}-aarch64-apple-darwin.tar.gz";
      sha256 = "0alyr5pryspk521kqp6l13dxayaq3l0i6kcgk743jbmi28s102bd";
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

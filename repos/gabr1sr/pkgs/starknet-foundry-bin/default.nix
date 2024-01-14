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
  bins = [ "snforge" "sncast" ];
in
stdenv.mkDerivation {
  pname = "starknet-foundry-bin";
  version = "0.14.0";

  src = fetchzip {
    url = "https://github.com/foundry-rs/starknet-foundry/releases/download/v0.14.0/starknet-foundry-v0.14.0-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "0yrw9mg4hmn9zpw6v4rxl6s18gsdhpd7zk5qwc6xxrg642g93vg8";
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
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
  };
}

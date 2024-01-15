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
      url = "https://github.com/software-mansion/scarb/releases/download/v2.4.3/scarb-v2.4.3-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "0c1sdsjqhl62rp2m7ljqazqdwhq9lnxq55pjgdwl5xxdkiswjr1z";
    };

    "aarch64-linux" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v2.4.3/scarb-v2.4.3-aarch64-unknown-linux-gnu.tar.gz";
      sha256 = "0dgvxg161bgx59jmzk670hknkbjn9132jvlcz6h9zbdprki6fry7";
    };

    "x86_64-darwin" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v2.4.3/scarb-v2.4.3-x86_64-apple-darwin.tar.gz";
      sha256 = "1qy5gsjlsq4wqb2963ab8s7c0ryh7fgphpqxdrfvbwk09siyinw7";
    };

    "aarch64-darwin" = {
      url = "https://github.com/software-mansion/scarb/releases/download/v2.4.3/scarb-v2.4.3-aarch64-apple-darwin.tar.gz";
      sha256 = "1as1xm83pabcxlmq3k8lxb5lnc0ibxi8fgvxg1hcjdgn6f55rsz2";
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
  version = "2.4.3";

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

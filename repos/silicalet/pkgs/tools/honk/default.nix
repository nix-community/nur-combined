{
  lib,
  stdenv,
  buildPackages,
  callPackage,
  fetchFromGitHub,
  pkg-config,
  cmake,
  clang,
  git,
  perl,
  rustPlatform,
  rust-bin,
  craneLib,
  versionCheckHook,
  withDoona ? true,
}:

let
  version = "0.1.0-beta.6";
  src = fetchFromGitHub {
    owner = "daeuniverse";
    repo = "honk";
    tag = "v${version}";
    hash = "sha256-jWfRf9LCK8mX44NHwm4ZQFp8bFGJZydI0qHkK2P/gm4=";
  };
  nightly = rust-bin.selectLatestNightlyWith (
    toolchain:
    toolchain.minimal.override {
      extensions = [ "rust-src" ];
      targets = lib.optional (
        stdenv.buildPlatform != stdenv.hostPlatform
      ) stdenv.hostPlatform.rust.rustcTarget;
    }
  );
  nightlyChannel = builtins.head (builtins.match "[0-9.]+-(nightly-[0-9-]+)" nightly.version);
  ebpf = buildPackages.callPackage ./ebpf.nix {
    inherit src version nightly;
    targetArch = stdenv.hostPlatform.uname.processor;
  };
  doonaAssets = callPackage ./doona.nix { inherit src; };
  features = "ebpf,rprx,jemalloc,${if withDoona then "clash-api,native-ui" else "native-api"}";
in
(craneLib.overrideToolchain nightly).buildPackage {
  inherit src version;
  pname = "honk-core";
  strictDeps = true;
  nativeBuildInputs = [
    pkg-config
    cmake
    clang
    perl
    rustPlatform.bindgenHook
    git
  ];
  env = {
    GITHUB_REF = "refs/tags/v${version}";
  }
  // lib.optionalAttrs withDoona {
    HONK_DOONA_DIR = "${doonaAssets}/doona";
  };
  # build.rs embeds the cached object only if its channel and freshness stamp agree.
  preBuild = ''
    printf '[toolchain]\nchannel = "%s"\n' ${nightlyChannel} > crates/honk-ebpf/rust-toolchain.toml
    install -Dm444 ${ebpf} target/honk-core.o
    printf %s ${nightlyChannel} > target/honk-core.toolchain
  '';
  cargoArtifacts = null;
  outputHashes = {
    "git+https://github.com/Glassyiris/boring-sys?rev=3beb573b65ecaa69b7eefe3c2fecd074b97facd2#3beb573b65ecaa69b7eefe3c2fecd074b97facd2" =
      "sha256-VG0POjZdA2JazFt1jFe4UfdO01Pw7E1EC/7u8fOmfBs=";
    "git+https://github.com/Glassyiris/quinn?rev=11f1de84c28305a3c98ace6d681c35219a8d1e6c#11f1de84c28305a3c98ace6d681c35219a8d1e6c" =
      "sha256-N3oMkQ+bL0TeObMv5kdODEz8jfQr4wAODKEWqx8aCNI=";
  };
  cargoExtraArgs = "--frozen -p honk-core --no-default-features --features ${features}";
  doCheck = false;
  passthru = { inherit withDoona; };
  postInstall = ''
    install -Dm444 LICENSE "$out/share/licenses/honk-core/LICENSE"
    install -Dm444 README.md "$out/share/doc/honk-core/README.md"
  ''
  + lib.optionalString withDoona ''
    for edition in doona doona-lite; do
      ui=${doonaAssets}/$edition
      cmp LICENSE "$ui/LICENSE"
      notices="$out/share/licenses/honk-core/$edition"
      install -Dm644 -t "$notices" "$ui/NOTICE" "$ui/THIRD-PARTY-NOTICES.txt"
      install -Dm644 -t "$notices/LICENSES" "$ui"/LICENSES/*
    done
  '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  meta = {
    description = "Experimental Linux eBPF transparent proxy engine built from source";
    homepage = "https://github.com/daeuniverse/honk";
    license = with lib.licenses; [ gpl3Only ] ++ lib.optionals withDoona [ asl20 ofl mit ];
    mainProgram = "honk-core";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}

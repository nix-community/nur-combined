{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.9.1";
  pname = "tunnet";

  # Prebuilt "headless" release tarballs (tunnet + tunnetd), keyed by Nix system.
  # Hashes come from the .sha256 assets published alongside them; update.sh rewrites both.
  sources = {
    "x86_64-linux" = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-qLZLesmkGZAXb6bdkGHUkQ8p4DFPDu1YOJAiYRmkces=";
    };
    "aarch64-linux" = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-HYr0wB6MBmli7zseG++QVhkdLM1x8YBjTN2mhwl5krg=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "${pname}: unsupported platform ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://github.com/tunnetio/Tunnet/releases/download/v${version}/tunnet-headless-${version}-${source.target}.tar.gz";
    inherit (source) hash;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  sourceRoot = "tunnet-headless-${version}-${source.target}";

  nativeBuildInputs = [ autoPatchelfHook ];

  # The binaries link only against glibc and libgcc_s.
  buildInputs = [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # tunnet resolves tunnetd next to its own argv[0], so they must stay together.
    install -Dm755 tunnet tunnetd -t $out/bin
    install -Dm644 LICENSE -t $out/share/doc/${pname}

    runHook postInstall
  '';

  meta = {
    description = "Encrypted peer-to-peer mesh network agent";
    longDescription = ''
      Tunnet builds an encrypted overlay network over QUIC (iroh) in which every machine
      gets an internal mesh IP and can reach every other machine. This package ships the
      mesh CLI (tunnet) and the agent daemon (tunnetd).

      tunnetd needs root (or CAP_NET_ADMIN) and /dev/net/tun. Do not use
      `tunnet service install` on NixOS: it writes /etc/systemd/system/tunnet.service.
      Use the services.tunnet module from this repository instead. Likewise `tunnet update`
      rewrites its own binary and cannot work from the Nix store; update the package.
    '';
    homepage = "https://tunnet.io";
    downloadPage = "https://github.com/tunnetio/Tunnet/releases";
    changelog = "https://github.com/tunnetio/Tunnet/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = lib.attrNames sources;
    mainProgram = "tunnet";
  };
}

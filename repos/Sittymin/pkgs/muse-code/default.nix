{ stdenv, fetchurl, makeWrapper, lib, git }:

let
  version = "0.2.1-R1215.1";

  # Binaries are published per-arch on Meta's lookaside CDN. They are
  # statically linked ELF executables, so no interpreter/patchelf dance is
  # needed on NixOS.
  hashes = {
    x86_64-linux = {
      file = "muse-x86-linux";
      hash = "sha256-v9hmCzpPzmerMoewvSfqZNse6EcujXyw8Pmqjgg8mVc=";
    };
    aarch64-linux = {
      file = "muse-aarch64-linux";
      hash = "sha256-8QiMESiEFTuBgICe8iTjd1t0AhXcnFZt/4xBCZK3Wx0=";
    };
  };

  selected = hashes.${stdenv.hostPlatform.system}
    or (throw "muse-code: unsupported platform ${stdenv.hostPlatform.system}");
in

stdenv.mkDerivation (finalAttrs: {
  pname = "muse-code";
  inherit version;

  src = fetchurl {
    url = "https://lookaside.facebook.com/lookaside/muse/download/?channel=muse&version=${version}&file=${selected.file}";
    hash = selected.hash;
  };

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    # Required at runtime for the worktree / subagent features.
    git
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/muse
    chmod +x $out/bin/muse

    # The upstream binary self-updates hourly by rewriting itself next to its
    # own path. Inside the Nix store that is read-only, so pin it here and
    # upgrade by bumping version/hash in this file and rebuilding.
    wrapProgram $out/bin/muse       --set MUSE_NO_AUTO_UPDATE 1       --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  meta = {
    description = "Muse Code - Meta's terminal coding agent powered by Muse Spark";
    homepage = "https://dev.meta.ai/docs/muse-code";
    platforms = lib.attrNames hashes;
    license = lib.licenses.unfreeRedistributable;
    mainProgram = "muse";
  };
})

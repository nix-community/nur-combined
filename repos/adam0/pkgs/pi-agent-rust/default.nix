{
  # keep-sorted start
  autoPatchelfHook,
  fetchurl,
  gcc,
  lib,
  stdenv,
  # keep-sorted end
}: let
  manifest = builtins.fromJSON (builtins.readFile ./release.json);
  inherit (manifest) version;
  inherit (stdenv.hostPlatform) system;

  target =
    {
      aarch64-linux = "aarch64-unknown-linux-gnu";
      x86_64-linux = "x86_64-unknown-linux-gnu";
    }.${
      system
    };
in
  stdenv.mkDerivation {
    pname = "pi-agent-rust";
    inherit version;

    src = fetchurl {
      url = "https://github.com/Dicklesworthstone/pi_agent_rust/releases/download/v${version}/${manifest.updater.assets.${system}}";
      hash = manifest.hashes.${system};
    };

    sourceRoot = "pi-${version}-${target}";

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs = [gcc.cc.lib];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 pi $out/bin/pi
      install -Dm644 README.md $out/share/doc/pi-agent-rust/README.md
      install -Dm644 LICENSE $out/share/licenses/pi-agent-rust/LICENSE

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/pi --version
    '';

    meta = {
      # keep-sorted start block=yes newline_separated=yes
      description = "Native AI coding agent CLI written in Rust";

      homepage = "https://github.com/Dicklesworthstone/pi_agent_rust";

      license = lib.licenses.unfree;

      mainProgram = "pi";

      platforms = [
        # keep-sorted start
        "aarch64-linux"
        "x86_64-linux"
        # keep-sorted end
      ];

      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      # keep-sorted end
    };
  }

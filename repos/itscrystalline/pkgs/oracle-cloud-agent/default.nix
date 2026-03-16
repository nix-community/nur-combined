{
  lib,
  stdenv,
  fetchurl,
  squashfsTools,
}:
stdenv.mkDerivation rec {
  pname = "oracle-cloud-agent";
  version = "1.56.0-7";

  src = fetchurl {
    url =
      {
        x86_64-linux = "https://api.snapcraft.io/api/v1/snaps/download/ltx4XjES2e2ujitNIuO5GxPYDM6lp6ry_113.snap";
        aarch64-linux = "https://api.snapcraft.io/api/v1/snaps/download/ltx4XjES2e2ujitNIuO5GxPYDM6lp6ry_114.snap";
      }
      .${
        stdenv.hostPlatform.system
      };
    hash =
      {
        x86_64-linux = "sha256-UO/mq0EJJGOLtigL1ofAY8VM6hqxY42JKSFc4O1sH9M=";
        aarch64-linux = "sha256-xRU0p+YFgrA2nIobqr38pKG3ugZ9c1WihGqcoA6t8Bc=";
      }
      .${
        stdenv.hostPlatform.system
      };
  };

  nativeBuildInputs = [squashfsTools];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    unsquashfs -d snap-src "$src"

    install -Dm755 snap-src/agent "$out/lib/oracle-cloud-agent/agent"
    install -Dm755 snap-src/updater/updater "$out/lib/oracle-cloud-agent/updater/updater"
    install -Dm644 snap-src/agent.yml "$out/lib/oracle-cloud-agent/agent.yml"
    install -Dm644 snap-src/updater.yml "$out/lib/oracle-cloud-agent/updater.yml"

    # plugins
    for plugin_dir in snap-src/plugins/*/; do
      plugin_name=$(basename "$plugin_dir")
      for f in "$plugin_dir"*; do
        fname=$(basename "$f")
        if [ -x "$f" ] && [ -f "$f" ]; then
          install -Dm755 "$f" "$out/lib/oracle-cloud-agent/plugins/$plugin_name/$fname"
        elif [ -f "$f" ]; then
          install -Dm644 "$f" "$out/lib/oracle-cloud-agent/plugins/$plugin_name/$fname"
        fi
      done
    done

    # diagnostic tool
    install -Dm755 snap-src/usr/libexec/oracle-cloud-agent/ocatools/diagnostic \
      "$out/lib/oracle-cloud-agent/ocatools/diagnostic"

    # symlink main binaries into $out/bin
    mkdir -p "$out/bin"
    ln -s "$out/lib/oracle-cloud-agent/agent" "$out/bin/oracle-cloud-agent"
    ln -s "$out/lib/oracle-cloud-agent/updater/updater" "$out/bin/oracle-cloud-agent-updater"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Oracle Cloud Infrastructure agent for compute instance management and monitoring";
    homepage = "https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/manage-plugins.htm";
    sourceProvenance = [sourceTypes.binaryNativeCode];
    license = licenses.upl;
    maintainers = [];
    platforms = ["x86_64-linux" "aarch64-linux"];
    mainProgram = "oracle-cloud-agent";
  };
}

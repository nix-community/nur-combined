{ lib, stdenv, fetchurl
, writeScript, makeWrapper
, gnugrep, gnused
, libmediainfo, libzen, jre
, yj, jq
}:
stdenv.mkDerivation rec {
  pname = "tinymediamanager";
  version = "4.3.4";

  src = fetchurl {
    url = "https://archive.tinymediamanager.org/v${version}/tmm_${version}_linux-amd64.tar.gz";
    sha256 = "1aj97m186lagaqqvcs2s7hmgk638l5mb98ril4gwgpjqaqj8s57n";
  };

  nativeBuildInputs = [
    makeWrapper
    gnugrep gnused
  ];

  nativeDeps = [
    libmediainfo libzen
  ];
  binDeps = [
    yj jq
  ];

  installPhase = ''
    # Install upstream package contents and strip some unnecessary stuff
    mkdir -p $out/share
    cp -r ./ $out/share/tinyMediaManager
    rm -rf $out/share/tinyMediaManager/{jre,native,tinyMediaManager}

    # Parse out the Java options we need
    cat $out/share/tinyMediaManager/getdown.txt | grep -E "jvmarg = (\[linux] )?-" | grep -o -- "-.*" | sed 's/^/JAVA_OPTS="$JAVA_OPTS /' | sed 's/$/"/' | grep -v "Xmx" >> $out/share/tinyMediaManager/JAVA_OPTS

    # Setup the wrapper script
    mkdir -p $out/bin
    install -D "$launchScript" "$out/bin/tinymediamanager"

    wrapProgram "$out/bin/tinymediamanager" \
      --prefix LD_LIBRARY_PATH : ${lib.escapeShellArg (lib.makeLibraryPath nativeDeps)} \
      --prefix PATH : ${lib.escapeShellArg (lib.makeBinPath binDeps)}
  '';

  launchScript = writeScript "tinymediamanager" ''
    #!/usr/bin/env bash
    set -e
    SOURCE_DIR=$(cd "$(dirname "''${BASH_SOURCE[0]}")" && pwd)
    BASE_DIR=$(cd "$SOURCE_DIR"/.. && pwd)
    SHARE_DIR="$BASE_DIR/share/tinyMediaManager"
    DOTDIR="$HOME/.local/share/tinymediamanager"

    mkdir -p "$DOTDIR/templates"
    ln -sf "$SHARE_DIR/templates/templates.tar.bz2" "$DOTDIR/templates/"

    # Source the package-provided JVM opts
    source "$SHARE_DIR/JAVA_OPTS"

    # If present, source application-configured JVM opts
    LAUNCHER_OPTS_FILE="$DOTDIR/launcher-extra.yml"
    if [[ -f "$LAUNCHER_OPTS_FILE" ]]; then
      while read -r opt; do
        JAVA_OPTS="$JAVA_OPTS $opt"
      done < <(cat "$LAUNCHER_OPTS_FILE" | yj | jq -rc '.jvmOpts[]')
    fi

    cd "$DOTDIR"
    ${jre}/bin/java $JAVA_OPTS \
      -Dappbase=https://www.tinymediamanager.org/ \
      -cp "$SHARE_DIR/tmm.jar:$SHARE_DIR/lib/*" \
      org.tinymediamanager.TinyMediaManager "$@"
  '';

  meta = with lib; {
    description = "tinyMediaManager is a media management tool written in Java, designed to provide metadata for the Kodi Media Center, MediaPortal and Plex media server";
    homepage = https://www.tinymediamanager.org/;
    maintainers = with maintainers; [ arobyn ];
    platforms = platforms.linux;
    license = licenses.asl20;
  };
}


{
  fetchurl,
  lib,
  stdenv,
  p7zip,
  rpmextract,
  makeWrapper,
  bubblewrap,
  pkgsi686Linux,
}:
let
  pname = "red-star-os-rgjanggi";
  version = "3.0";
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Rgjanggi game from DPRK Red Star OS 3.0, heavily sandboxed. Use at your own risk";
    homepage = "https://archive.org/details/RedStarOS";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };

  src = stdenv.mkDerivation {
    inherit pname version;
    src = fetchurl {
      url = "https://archive.org/download/RedStarOS/Red%20Star%20OS%203.0%20Desktop/DESKTOP_redstar_desktop3.0_sign.iso";
      hash = "sha256-iVrQ4Brg01pl6axC3TTQodaF1t+jMc5bTyS7x1NDm+M=";
    };

    nativeBuildInputs = [
      p7zip
      rpmextract
    ];

    unpackPhase = ''
      runHook preUnpack

      7z x $src RedStar/RPMS/rgjanggi-3.0-1.i386.rpm

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      BUILD_DIR=$(pwd)
      pushd $out
      rpmextract $BUILD_DIR/RedStar/RPMS/rgjanggi-3.0-1.i386.rpm
      popd

      runHook postInstall
    '';

    inherit meta;
  };

  wxGTK2 = pkgsi686Linux.callPackage ./wxgtk2.nix { unicode = false; };

  additionalPath = lib.makeBinPath [
    pkgsi686Linux.alsa-utils
  ];

  package = pkgsi686Linux.stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs = with pkgsi686Linux; [
      autoPatchelfHook
    ];

    buildInputs = [ wxGTK2 ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin $out/opt $out/lib
      cp -r $src/Applications $out/opt/Applications

      runHook postInstall
    '';

    inherit meta;
  };
in
stdenv.mkDerivation rec {
  inherit pname version;
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cat <<EOF >$out/bin/rgjanggi
    #!/usr/bin/env bash

    # Copied from FHS setup script
    declare -a x11_args
    # Always mount a tmpfs on /tmp/.X11-unix
    # Rationale: https://github.com/flatpak/flatpak/blob/be2de97e862e5ca223da40a895e54e7bf24dbfb9/common/flatpak-run.c#L277
    x11_args+=(--tmpfs /tmp/.X11-unix)

    # Try to guess X socket path. This doesn't cover _everything_, but it covers some things.
    if [[ "\$DISPLAY" == *:* ]]; then
      # recover display number from \$DISPLAY formatted [host]:num[.screen]
      display_nr=\''${DISPLAY/#*:} # strip host
      display_nr=\''${display_nr/%.*} # strip screen
      local_socket=/tmp/.X11-unix/X\$display_nr
      x11_args+=(--ro-bind-try "\$local_socket" "\$local_socket")
    fi

    if [[ "\$XAUTHORITY" != "" ]]; then
      x11_args+=(--ro-bind-try "\$XAUTHORITY" "\$XAUTHORITY")
    fi

    exec ${bubblewrap}/bin/bwrap \
      --unshare-all \
      --tmpfs / \
      --dev-bind /dev /dev \
      --proc /proc \
      --die-with-parent \
      --ro-bind /etc /etc \
      --ro-bind /nix /nix \
      --ro-bind ${package}/opt/Applications /Applications \
      --bind /run /run \
      --tmpfs /tmp \
      --tmpfs /home/\$USER \
      "\''${x11_args[@]}" \
      --chdir / \
      ${package}/opt/Applications/rgjanggi.app/Contents/RedStar/rgjanggi
    EOF
    chmod +x $out/bin/rgjanggi

    wrapProgram $out/bin/rgjanggi \
      --suffix PATH : "${additionalPath}"

    runHook postInstall
  '';

  inherit meta;
}

{ stdenv
, fetchurl
, autoPatchelfHook
, writeShellScript
, bubblewrap
, lib
  # Dependencies
, cairo
, gdk-pixbuf
, glib
, gtk2
, nspr
, nss
, pango
, xorg
, ...
} @ args:

################################################################################
# Mostly based on linuxqq package from AUR:
# https://aur.archlinux.org/packages/linuxqq
################################################################################

let
  libraries = [
    cairo
    gdk-pixbuf
    glib
    gtk2
    nspr
    nss
    pango
    xorg.libX11
  ];

  qq = stdenv.mkDerivation rec {
    pname = "qq";
    version = "2.0.0-b2-1089";
    src = fetchurl {
      url = "https://down.qq.com/qqweb/LinuxQQ/linuxqq_${version}_x86_64.pkg.tar.xz";
      sha256 = "sha256-EyTMS7QUev0kkMHPQEW2r6N49J2IIaELJaRqg7Qgz/k=";
    };

    nativeBuildInputs = [ autoPatchelfHook ];
    buildInputs = libraries;

    installPhase = ''
      mkdir -p $out
      cp -r local/bin $out/bin
      cp -r local/share $out/share
      cp -r share/applications $out/share/applications
    '';
  };

  startScript = writeShellScript "qq" ''
    blacklist=(/home /nix /dev /usr /lib /lib64 /proc)

    declare -a auto_mounts
    # loop through all directories in the root
    for dir in /*; do
      # if it is a directory and it is not in the blacklist
      if [[ -d "$dir" ]] && [[ ! "''${blacklist[@]}" =~ "$dir" ]]; then
        # add it to the mount list
        auto_mounts+=(--bind "$dir" "$dir")
      fi
    done

    [ -z "''${XAUTHORITY}" ] && export XAUTHORITY=/tmp/fake-Xauthority
    touch ''${XAUTHORITY}

    cmd=(
      ${bubblewrap}/bin/bwrap
      --dev-bind /dev /dev
      --chdir "''${HOME}"
      --die-with-parent
      --ro-bind /nix /nix
      --proc /proc
      --bind ${qq}/share/tencent-qq /usr/local/share/tencent-qq
      --bind ''${HOME}/.local/share/qq ''${HOME}
      --bind ''${XAUTHORITY} ''${XAUTHORITY}
      "''${auto_mounts[@]}"
      ${qq}/bin/qq "$@"
    )

    mkdir -p ''${HOME}/.local/share/qq
    exec "''${cmd[@]}"
  '';
in
stdenv.mkDerivation rec {
  inherit (qq) pname version;
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/pixmaps
    ln -s ${startScript} $out/bin/qq
    ln -s ${qq}/share/tencent-qq/qq.png $out/share/pixmaps/qq.png

    cp ${qq}/share/applications/qq.desktop $out/share/applications/qq.desktop
    sed -i "s|Exec=.*|Exec=$out/bin/qq|" $out/share/applications/qq.desktop
    sed -i "s|Icon=.*|Icon=$out/share/pixmaps/qq.png|" $out/share/applications/qq.desktop
  '';

  meta = with lib; {
    description = "Tencent QQ for Linux";
    homepage = "https://im.qq.com/linuxqq";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}

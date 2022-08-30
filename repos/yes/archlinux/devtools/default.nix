{ lib
, stdenvNoCC
, fetchzip
, arch-install-scripts
, asciidoc
, bash
, binutils
, breezy
, btrfs-progs
, coreutils
, curl
, diffutils
, gawk
, gettext
, git
, glibc
, gnum4
, mercurial
, openssh
, pacman
, rsync
, subversion
, systemd
, util-linux
, zstd
, rp ? ""
}:

let
  path = lib.strings.makeBinPath [
    "/run/wrappers"
    "${placeholder "out"}"
    arch-install-scripts
    binutils
    breezy
    btrfs-progs
    coreutils
    diffutils
    gawk
    gettext
    git
    glibc
    mercurial
    openssh
    pacman
    rsync
    subversion
    systemd
    util-linux
  ];

in stdenvNoCC.mkDerivation rec {
  pname = "devtools";
  version = "20220621";

  src = fetchzip {
    url = "${rp}https://gitlab.archlinux.org/archlinux/devtools/-/archive/${version}/devtools-${version}.zip";
    hash = "sha256-p7UiZg18K5frrC3td/Ewty2AnzKUogSiKj/0yeF3338=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  nativeBuildInputs = [ asciidoc gnum4 ];

  preBuild = ''
    for script in \
      ./lib/common.sh \
      ./makechrootpkg.in \
      ./makerepropkg.in \
      ./offload-build.in \
      ./sogrep.in
    do
      substituteInPlace $script --replace "/usr/share/makepkg" "${pacman}/share/makepkg"
    done
    for conf in makepkg*.conf; do
      substituteInPlace $conf \
        --replace "/usr/bin/curl" "${curl}/bin/curl" \
        --replace "/usr/bin/rsync" "${rsync}/bin/rsync" \
        --replace "/usr/bin/scp" "${openssh}/bin/scp"
    done
    substituteInPlace ./offload-build.in --replace "/usr/share/devtools" "$out/share/devtools"
    echo "export PATH=${path}:$PATH" >> ./lib/common.sh
  '';

  meta = with lib; {
    description = "[Experimental] Tools for Arch Linux package maintainers";
    homepage = "https://gitlab.archlinux.org/archlinux/devtools";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
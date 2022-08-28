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
    for file in \
      ./lib/common.sh \
      ./makechrootpkg.in \
      ./makerepropkg.in \
      ./offload-build.in \
      ./sogrep.in
    do
      substituteInPlace $file --replace "/usr/share/makepkg" "${pacman}/share/makepkg"
    done
    # for file in ./commitpkg.in ./rebuildpkgs.in; do
    #   substituteInPlace $file --replace "'/etc/makepkg.conf'" "'${pacman}/etc/makepkg.conf'"
    # done
    substituteInPlace ./offload-build.in --replace "/usr/share/devtools" "$out/share/devtools"
    echo "export PATH=${path}:$PATH" >> ./lib/common.sh
  '';

  # postFixup = ''
  #   for script in $out/bin/*; do
  #     if [ -h $script ]; then
  #       target=$(readlink -f $script)
  #       rm -v $script
  #       cp -v $target $script
  #     fi
  #     wrapProgram $script --prefix PATH : ${path}
  #   done
  # '';

  meta = with lib; {
    description = "[WIP] Tools for Arch Linux package maintainers";
    homepage = "https://gitlab.archlinux.org/archlinux/devtools";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
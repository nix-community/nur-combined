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
, fetchFromGitHub
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

  f = fetchFromGitHub {
    owner = "YisuiDenghua";
    repo = "rvconfs2";
    rev = "5c1376bd0be0a0cff75b1aa3e4d1a6bf0787430c";
    sha256 = "sha256-mpfSnT6+ZDfmND0iYpI/0lvBMKWc2p+V3+nKmstO/wI=";
  };


in stdenvNoCC.mkDerivation rec {
  pname = "devtools-riscv64";
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


  postInstall = ''
    mkdir custom-configs
    pushd custom-configs

    cp ${f}/*.conf ./
    for conf in makepkg-*.conf; do
      substituteInPlace $conf \
        --replace "/usr/bin/curl" "${curl}/bin/curl" \
        --replace "/usr/bin/rsync" "${rsync}/bin/rsync" \
        --replace "/usr/bin/scp" "${openssh}/bin/scp"
    done
    cp makepkg-riscv64.conf $out/share/devtools/
    cp pacman-extra-riscv64.conf $out/share/devtools/
    chmod 644 "$out/share/devtools/makepkg-riscv64.conf"
    chmod 644 "$out/share/devtools/pacman-extra-riscv64.conf"
    echo "$CARCH" > $out/share/devtools/setarch-aliases.d/riscv64
    mkdir -p $out/{lib/binfmt.d,etc}
    cp z-archriscv-qemu-riscv64.conf $out/lib/binfmt.d/
    cp z-archriscv-qemu-riscv64.conf $out/etc/
    cp z-archriscv-qemu-riscv64.conf $out/share/devtools
    ln -s /usr/bin/archbuild $out/bin/extra-riscv64-build

    popd
  '';

  meta = with lib; {
    description = "[Experimental] Tools for Arch Linux package maintainers RISC-V";
    homepage = "https://github.com/felixonmars/archriscv-packages";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}

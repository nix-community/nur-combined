{ lib
, stdenv
, fetchpatch
, fetchurl
, asciidoc
, bzip2
, coreutils
, curl
, gnupg
, gpgme
, installShellFiles
, libarchive
, makeWrapper
, meson
, ninja
, openssl
, perl
, pkg-config
, xz
, zlib
, rp ? ""
}:

stdenv.mkDerivation rec {
  pname = "pacman";
  version = "6.0.1";

  src = fetchurl {
    url = "${rp}https://sources.archlinux.org/other/${pname}/${pname}-${version}.tar.xz";
    hash = "sha256-DbYUVuVqpJ4mDokcCwJb4hAxnmKxVSHynT6TsA079zE=";
  };

  nativeBuildInputs = [
    asciidoc
    installShellFiles
    makeWrapper
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    bzip2
    curl
    gpgme
    libarchive
    openssl
    perl
    xz
    zlib
  ];

  patches = [
    # Add keyringdir meson option to configure the keyring directory
    (fetchpatch {
      url = "${rp}https://gitlab.archlinux.org/pacman/pacman/-/commit/79bd512181af12ec80fd8f79486fc9508fa4a1b3.patch";
      hash = "sha256-ivTPwWe06Q5shn++R6EY0x3GC0P4X0SuC+F5sndfAtM=";
    })
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace "install_dir : SYSCONFDIR" "install_dir : '$out/etc'" \
      --replace "join_paths(DATAROOTDIR, 'libalpm/hooks/'))" "'/usr/share/libalpm/hooks/')" \
      --replace "join_paths(LOCALSTATEDIR, 'lib/pacman/')," "'$out/var/lib/pacman/'," \
      --replace "join_paths(LOCALSTATEDIR, 'cache/pacman/pkg/')," "'$out/var/cache/pacman/pkg/'," \
      --replace "join_paths(PREFIX, DATAROOTDIR, get_option('keyringdir'))" "'\$KEYRING_IMPORT_DIR'"
    substituteInPlace doc/meson.build \
      --replace "/bin/true" "${coreutils}/bin/true"
    substituteInPlace scripts/repo-add.sh.in \
      --replace bsdtar "${libarchive}/bin/bsdtar"
    substituteInPlace scripts/pacman-key.sh.in \
      --replace "local KEYRING_IMPORT_DIR='@keyringdir@'" "" \
      --subst-var-by keyringdir '\$KEYRING_IMPORT_DIR' \
      --replace "--batch --check-trustdb" "--batch --check-trustdb --allow-weak-key-signatures"
  ''; # the line above should be removed once Arch migrates to gnupg 2.3.x

  mesonFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    "-Dmakepkg-template-dir=${placeholder "out"}/share/makepkg-template"
  ];

  postInstall = ''
    installShellCompletion --bash scripts/pacman --zsh scripts/_pacman
    wrapProgram $out/bin/pacman-key \
      --prefix PATH : ${lib.makeBinPath [ gnupg ]}
    rm -rf "$out/{var,share/libalpm}"
  '';

  meta = with lib; {
    description = "A simple library-based package manager";
    homepage = "https://archlinux.org/pacman/";
    changelog = "https://gitlab.archlinux.org/pacman/pacman/-/raw/v${version}/NEWS";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}

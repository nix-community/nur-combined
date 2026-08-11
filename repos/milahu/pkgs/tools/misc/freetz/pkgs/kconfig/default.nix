# TODO generate this nix file from
# freetz/make/host-tools/kconfig-host/kconfig-host.mk

{ lib
, stdenv
, fetchgit
, fetchFromGitHub
, freetz
, flex
, bison
, pkg-config
, ncurses
, gtk2
, glib
, gnome2
, qt5
, configButtons ? false
}:

stdenv.mkDerivation rec {
  pname = "kconfig";

  # $(call TOOLS_INIT, v6.9)
  version = "6.9";

  # $(PKG)_SITE:=git_archive@git://repo.or.cz/linux.git,scripts/basic,scripts/kconfig,...
  src = fetchgit {
    #url = "git://repo.or.cz/linux.git";
    url = "https://github.com/torvalds/linux";
    rev = "v${version}";
    nonConeMode = true; # strict sparse checkout
    sparseCheckout = [
      "scripts/basic"
      "scripts/kconfig"
      "scripts/Kbuild.include"
      "scripts/Makefile.compiler"
      "scripts/Makefile.build"
      "scripts/Makefile.host"
      "scripts/Makefile.lib"
      "Documentation/kbuild/kconfig-language.rst"
      "Documentation/kbuild/kconfig-macro-language.rst"
      "Documentation/kbuild/kconfig.rst"
    ];

    # $(PKG)_SOURCE:=kconfig-$($(PKG)_VERSION).tar.xz
    # $(PKG)_HASH:=48a0e5e5ce72f0b23a868e2ce784033fadfdc7b3b199be5ef6efbfca02e0be70

    # $ sha256sum kconfig-v6.9.tar.xz
    # 48a0e5e5ce72f0b23a868e2ce784033fadfdc7b3b199be5ef6efbfca02e0be70  kconfig-v6.9.tar.xz

    # https://github.com/Freetz-NG/freetz-ng/discussions/990
    # how are the tar.xz archives created? are they reproducible?

    hash = "sha256-93NvPOAN/QzRX2/wJf12+/rdTmNIqtHsC/4ozpQBe2k=";
  };

  makeFlags = [
    # fix: Unable to find the ncurses package.
    #"HOSTPKG_CONFIG=pkgconf" # original
    "HOSTPKG_CONFIG=pkg-config"
    # fix wrong srctree: /build/linux/scripts
    # srctree is patched by 100-main_makefile.patch
    #"KBUILD_SRC=/build/linux"
  ];

  # aka "makeTargets" https://github.com/NixOS/nixpkgs/issues/28047
  # printf '"%s"\n' $(xclip -o)
  buildFlags = [

    # $(PKG)_TARGET_PRG := conf   mconf      nconf   gconf   gconf.glade qconf
    # make: *** No rule to make target 'conf'.  Stop.
    #"conf" "mconf" "nconf" "gconf" "gconf.glade" "qconf" 

    # $(PKG)_TARGET_ARG := config menuconfig nconfig gconfig gconfig     xconfig
    "config" "menuconfig" "nconfig" "gconfig" "gconfig" "xconfig" 

  ];

  extraPatchDirs = if configButtons then "buttons" else "";

  postPatch = ''
    for dir in "" $extraPatchDirs; do
      while read patch; do
        echo "applying $patch"
        patch --no-backup-if-mismatch -p0 < $patch
      done < <(
        find ${freetz.src}/make/host-tools/${pname}-host/patches/$dir -maxdepth 1 -type f | sort
      )
    done
  '';

  # $(PKG)_BUILD_PREREQ += bison flex
  nativeBuildInputs = [
    flex
    bison
    pkg-config # called but not needed
    qt5.wrapQtAppsHook # TODO wrap only qconf
  ];

  buildInputs = [
    ncurses
    gtk2 # gtk+-2.0
    glib # gmodule-2.0
    gnome2.libglade # libglade-2.0
    qt5.qtbase # Qt5Core Qt5Gui Qt5Widgets
  ];

  # fix: make: *** No rule to make target 'install'.  Stop.
  installPhase = ''
    dst=$out/opt/freetz/source/host-tools/${pname}-v${version}
    mkdir -p $(dirname $dst)
    cp -r . $dst
  '';

  meta = with lib; {
    description = "Standalone kconfig, extracted from the Linux kernel";
    homepage = "https://github.com/torvalds/linux";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "conf";
    platforms = platforms.all;
  };
}

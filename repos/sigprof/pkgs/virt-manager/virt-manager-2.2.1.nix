{
  lib,
  fetchurl,
  fetchpatch,
  python3Packages,
  intltool,
  file,
  wrapGAppsHook,
  gtk-vnc,
  vte,
  avahi,
  dconf,
  gobject-introspection,
  libvirt-glib,
  system-libvirt,
  gsettings-desktop-schemas,
  glib,
  libosinfo,
  gnome,
  gtksourceview4,
  spiceSupport ? true,
  spice-gtk ? null,
  cpio,
  e2fsprogs,
  findutils,
  gzip,
}:
with lib;
  python3Packages.buildPythonApplication rec {
    pname = "virt-manager";
    version = "2.2.1";

    src = fetchurl {
      url = "http://virt-manager.org/download/sources/virt-manager/${pname}-${version}.tar.gz";
      sha256 = "06ws0agxlip6p6n3n43knsnjyd91gqhh2dadgc33wl9lx1k8vn6g";
    };

    nativeBuildInputs = [
      intltool
      file
      gobject-introspection # for setup hook populating GI_TYPELIB_PATH
    ];

    buildInputs =
      [
        wrapGAppsHook
        libvirt-glib
        vte
        dconf
        gtk-vnc
        gnome.adwaita-icon-theme
        avahi
        gsettings-desktop-schemas
        libosinfo
        gtksourceview4
        gobject-introspection # Temporary fix, see https://github.com/NixOS/nixpkgs/issues/56943
      ]
      ++ optional spiceSupport spice-gtk;

    propagatedBuildInputs = with python3Packages; [
      pygobject3
      libvirt
      libxml2
      requests
    ];

    patches = [
      # due to a recent change in setuptools-61, "packages=[]" needs to be included
      (fetchpatch {
        name = "fix-for-setuptools-61.patch";
        url = "https://github.com/virt-manager/virt-manager/commit/46dc0616308a73d1ce3ccc6d716cf8bbcaac6474.patch";
        sha256 = "sha256-/RZG+7Pmd7rmxMZf8Fvg09dUggs2MqXZahfRQ5cLcuM=";
      })
    ];

    postPatch = ''
      sed -i 's|/usr/share/libvirt/cpu_map.xml|${system-libvirt}/share/libvirt/cpu_map.xml|g' virtinst/capabilities.py
      sed -i "/'install_egg_info'/d" setup.py
    '';

    postConfigure = ''
      ${python3Packages.python.interpreter} setup.py configure --prefix=$out
    '';

    setupPyGlobalFlags = ["--no-update-icon-cache"];

    preFixup = ''
      gappsWrapperArgs+=(--set PYTHONPATH "$PYTHONPATH")
      # these are called from virt-install in initrdinject.py
      gappsWrapperArgs+=(--prefix PATH : "${makeBinPath [cpio e2fsprogs file findutils gzip]}")
    '';

    # Failed tests
    doCheck = false;

    meta = with lib; {
      homepage = "http://virt-manager.org";
      description = "Desktop user interface for managing virtual machines";
      longDescription = ''
        The virt-manager application is a desktop user interface for managing
        virtual machines through libvirt. It primarily targets KVM VMs, but also
        manages Xen and LXC (linux containers).
      '';
      license = licenses.gpl2;
      # exclude Darwin since libvirt-glib currently doesn't build there
      platforms = platforms.linux;
      maintainers = with maintainers; [qknight offline fpletz globin];
    };
  }

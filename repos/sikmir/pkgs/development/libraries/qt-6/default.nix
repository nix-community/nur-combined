# https://gist.github.com/rprospero/dd8e16bad9f842409c85e63ade31c355
{ lib, stdenv, fetchurl, requireFile, python3Packages, p7zip, libmysqlclient, autoPatchelfHook
, dbus, libxkbcommon, gdk-pixbuf, libdrm, libgssglue, mysql, gtkd
, cups, pango, postgresql, libGL, libglvnd, xorg, unixODBC }:

let
  aqt = python3Packages.buildPythonPackage rec {
    pname = "aqtinstall";
    version = "1.2.4";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "fmaAYOSHrx5LVUoPlIw0p/0jMRVGSPE+teEVlNurz10=";
    };
    propagatedBuildInputs = [
      python3Packages.setuptools-scm
      python3Packages.texttable
      python3Packages.patch
      python3Packages.requests
      semantic_version
      p7zip
    ];
    pipInstallFlags = [ "--no-deps" ];

    doCheck = false;
  };

  semantic_version = python3Packages.buildPythonPackage rec {
    pname = "semantic_version";
    version = "2.8.5";
    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "0sst4FWHYpNGebmhBOguynr0SMn0l00fPuzP9lHfilQ=";
    };
    # propagatedBuildInputs =
    #   [ python3Packages.setuptools-scm python3Packages.semantic_verion ];
    # pipInstallFlags = [ "--no-deps" ];

    doCheck = false;
  };

  qtbase = requireFile {
    name = "6.1.1-0-202106031044qtbase-Linux-CentOS_8_3-GCC-Linux-CentOS_8_3-X86_64.7z";
    message = ''
      Download https://mirrors.ukfast.co.uk/sites/qt.io/online/qtsdkrepository/linux_x64/desktop/qt6_611/qt.qt6.611.gcc_64/6.1.1-0-202106031044qtbase-Linux-CentOS_8_3-GCC-Linux-CentOS_8_3-X86_64.7z
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "fcE1ShAuAbKPihOG4OILnijM0mgAsa5l8V8V1bOYykM=";
  };
  qtsvg = requireFile {
    name = "6.1.1-0-202106031044qtsvg-Linux-CentOS_8_3-GCC-Linux-CentOS_8_3-X86_64.7z";
    message = ''
      Download https://mirrors.ukfast.co.uk/sites/qt.io/online/qtsdkrepository/linux_x64/desktop/qt6_611/qt.qt6.611.gcc_64/6.1.1-0-202106031044qtsvg-Linux-CentOS_8_3-GCC-Linux-CentOS_8_3-X86_64.7z
      and add it to the nix store with nix-store --add-fixed sha256 <FILE>.
    '';
    sha256 = "zO9CAMNN7k5k51V4JcrCZFbAag3sn2gmd0YoYvh+qng=";
  };

in stdenv.mkDerivation {
  pname = "qt6";
  version = "6.1.1";
  unpackPhase = ''
    ${p7zip}/bin/7z x ${qtbase} -o$out
    ${p7zip}/bin/7z x ${qtsvg} -o$out
  '';
  installPhase = ''
    mkdir $out/lib
    ln -s ${libmysqlclient}/lib/mysql/libmysqlclient.so $out/lib/libmysqlclient.so.21
    patchelf --set-rpath $out/lib $out/6.1.1/gcc_64/lib/libQt6Core.so.6.1.1
    echo No Install
  '';
  nativeBuildInputs = [ autoPatchelfHook ];
  autoPatchelfIgnoreMissingDeps = false;
  buildInputs = [
    dbus
    libxkbcommon
    stdenv.cc.cc.lib

    gdk-pixbuf
    libdrm
    (import ./icu.nix {
      inherit lib stdenv fetchurl;
      version = "56.1";
      sha256 = "OmTpEFxzTc9jHAs+1gQEUxvObA9aZL/hpkAqTMIxSBY=";
    })
    libgssglue
    mysql
    libmysqlclient.dev
    gtkd

    cups
    pango
    postgresql
    libGL
    libglvnd
    libglvnd.dev
    xorg.xcbutil
    xorg.xcbutilwm
    xorg.xcbutilkeysyms
    xorg.xcbutilimage
    xorg.xcbutilrenderutil
    unixODBC
  ];

  meta = with lib; {
    homepage = "http://www.qt.io";
    description = "A cross-platform application framework for C++";
    license = with licenses; [ fdl13 gpl2 lgpl21 lgpl3 ];
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = true;
  };
}

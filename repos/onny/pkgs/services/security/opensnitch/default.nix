{ lib, stdenv, pkgs, python3Packages, fetchFromGitHub, libnetfilter_queue
, libnfnetlink, libpcap, protobuf, buildGoPackage, pkg-config
, qt5
}:

let
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "gustavo-iniguez-goya";
    repo = "opensnitch";
    rev = "v${version}";
    sha256 = "03xlzj2mwh5vckvi0fq33x60p9g28aplilk8r44q65ia88g1dwkf";
  };
  meta = {
    description = "GNU/Linux port of the Little Snitch application firewall";
    license = lib.licenses.gpl3;
    homepage = "https://github.com/gustavo-iniguez-goya/opensnitch";
    platforms = lib.platforms.unix;
  };
in

{
  opensnitchd = buildGoPackage rec {
    pname = "opensnitch-daemon";
    inherit src version meta;
    goPackagePath = "github.com/gustavo-iniguez-goya/opensnitch";
    subPackages = [ "./daemon" ];
    goDeps = ./deps.nix;
    buildInputs = [ pkg-config libnetfilter_queue libnfnetlink libpcap protobuf ];
    postInstall = "mv $bin/bin/daemon $bin/bin/opensnitchd";
  };

  opensnitch-ui = python3Packages.buildPythonApplication rec {
    pname = "opensnitch-ui";
    inherit src version meta;
    sourceRoot = "source/ui";
    dontWrapPythonPrograms = true;
    nativeBuildInputs = [ qt5.wrapQtAppsHook stdenv python3Packages.pyqt5 ];
    preBuild = ''
      pyrcc5 -o opensnitch/resources_rc.py opensnitch/res/resources.qrc
    '';
    propagatedBuildInputs = with python3Packages; [
      grpcio
      grpcio-tools
      pyinotify
      configparser
      pyqt5
      unicode-slugify
    ] ;
    doCheck = false;
    postInstall = ''
      for program in $out/bin/*; do
      wrapQtApp $program --prefix PYTHONPATH : $PYTHONPATH
      done
    '';
  };
}


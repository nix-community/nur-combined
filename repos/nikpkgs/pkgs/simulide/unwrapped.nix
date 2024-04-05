{ stdenv
, pkgs
, lib
, qtbase
, qtscript
, qtserialport
, qtmultimedia
, qmake
, wrapQtAppsHook
, makeWrapper
, fetchurl
}:
with lib;
let
  name = "simulide";
  author = "~arcachofo";
  version = "1.0.1";
  src = fetchurl {
    name = "${name}-${version}.tar.gz";
    url = "https://bazaar.launchpad.net/${author}/${name}/${version}/tarball/1425?start_revid=1425";
    sha256 = "sha256-8BkCLhlTcXVQSV9qd1iy6eBuoptj6MPZ6o5LBvBfxhA=";
  };
in stdenv.mkDerivation {
  inherit version src;

  pname = "${name}-unwrapped";

  sourceRoot = "${author}/${name}/${version}";
  buildDir = "build_XX";

  buildInputs       = [ qtbase qtscript qtserialport qtmultimedia pkgs.arduino ];
  nativeBuildInputs = [ qmake wrapQtAppsHook pkgs.breezy pkgs.which ];

  # Prefix must be set correctly due to sed -i "s?X-PREFIX-X?$(PREFIX)?"
  makeFlags = [ "PREFIX=$(out)" ]; # prefix does not work since due to line "install -d $(DESTDIR)/etc/xdg/"

  # nix can be sometimes utterly retarded so this is the fix
  preConfigure = ''
    cd build_XX
  '';

  patches = [
    ./0000-fix-arduino-workdir.patch
  ];

  postInstall = ''
    # shortcut
    # install -D -m644  # one day

    # binary
    cd executables/SimulIDE_${version}

    mkdir $out/bin
    cp ${name} $out/bin

    # data
    mkdir -p $out/share/${name}
    cp -r ./ $out/share/${name}
    rm $out/share/${name}/${name}

    # icon
    cd ../../..
    mkdir -p $out/share/icons
    cp -r resources/icons/* $out/share/icons
  '';

  #dontWrapQtApps = true;
  #preFixup = ''
  #  wrapQtApp "$out/${name}"
  #  mkdir "$out/bin"
  #  ln -s "$out/${name}" "$out/bin/${name}"
  #'';

  meta = with lib; {
    description = "Electronic Circuit Simulator";
    homepage    = "https://code.launchpad.net/simulide";
    license     = licenses.gpl3;
  };
}


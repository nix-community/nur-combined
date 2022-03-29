{ lib
, buildPythonApplication
, fetchFromGitHub 
, pygobject3
, instantConf
, wrapGAppsHook
, gobject-introspection
, pango
, gdk-pixbuf
, atk
}:

buildPythonApplication {
  pname = "instantWelcome";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "instantWELCOME";
    rev = "d3152445de8509c6460dd0ffec3f23ace9af707a";
    sha256 = "1zrq9pwzdgjws49ijv9sfjnrj48zzn4gh0l2ngf09b9f162xj4b3";
  };

  postPatch = ''
    patchShebangs instantWELCOME/welcome.sh
    substituteInPlace instantWELCOME/welcome.py \
      --replace welcome.glade  "$out/share/welcome.glade"
  '';

  nativeBuildInputs = [
    wrapGAppsHook 
    gobject-introspection
    atk
    gdk-pixbuf
    pango
  ];
  propagatedBuildInputs = [ pygobject3 ];

  doCheck = false;

  postInstall = ''
    mkdir -p "$out/bin"
    install -Dm 644 instantWELCOME/welcome.glade "$out/share/welcome.glade"
    install -Dm 644 instantWELCOME/instantwelcome.desktop "$out/share/applications/instantwelcome.desktop"
    ln -s "$out/bin/welcome" "$out/bin/instantwelcome"
  '';

  meta = with lib; {
    description = "Welcome app for instantOS";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

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
let 
  pyModuleDeps = [
    pygobject3
  ];
  gnomeDeps = [
    wrapGAppsHook 
    gobject-introspection
    atk
    gdk-pixbuf
    pango
  ];
in
buildPythonApplication {
  pname = "instantWELCOME";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "instantWELCOME";
    rev = "2776c5ab66b436c747c35c06f03df667065c427e";
    sha256 = "1lrlwnc4n544i1w2z46irx6fvgz5i664d4kam15w2njfzz6wfhj3";
  };

  postPatch = ''
    patchShebangs instantWELCOME/welcome.sh
    substituteInPlace instantWELCOME/welcome.py \
      --replace welcome.glade  "$out/share/welcome.glade"
  '';
  
  nativeBuildInputs = gnomeDeps;
  buildInputs = pyModuleDeps ;
  propagatedBuildInputs = pyModuleDeps;

  doCheck = false;

  postInstall = ''
    mkdir -p "$out/bin"
    ln -s "$out/lib/python3.7/site-packages/instantWELCOME/welcome.sh" "$out/bin/instantwelcome"
    install -Dm 644 instantWELCOME/welcome.glade "$out/share/welcome.glade"
    install -Dm 644 instantWELCOME/instantwelcome.desktop "$out/share/applications/instantwelcome.desktop"
  '';

  meta = with lib; {
    description = "Welcome app for instantOS";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

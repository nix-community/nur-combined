{
  callPackage,
  fetchFromGitHub,
  wxGTK30,
  gcc8Stdenv,
}:
let
  # Fix mismatch between the program and library build versions
  wxGTK30_gcc8 =
    (wxGTK30.override {
      stdenv = gcc8Stdenv;
      compat26 = false;
    }).overrideAttrs
      (old: {
        version = "3.0.5";
        src = fetchFromGitHub {
          owner = "wxWidgets";
          repo = "wxWidgets";
          rev = "v3.0.5";
          sha256 = "1l33629ifx2dl2j71idqbd2qb6zb1d566ijpkvz6irrr50s6gbx7";
        };
      });
in
{
  cad = callPackage ./base.nix {
    pname = "TdhCad";
    version = "21.01.12";
    description = "Vector Graphics and Charting";
    homepage = "https://www.tdhcad.com";
    id = "1YYC1DvUSvmgReUVqwZT1ZKvwC7QYc9Yf";
    sha256 = "12b1kb9fn899r0f2n8p7yjihds57hcjn3gxr6plnq6qiz1nrnx7l";
    wxgtk = wxGTK30_gcc8;
  };

  gis = callPackage ./base.nix {
    pname = "TdhGIS";
    version = "21.01.03";
    description = "Vector Based Spatial Analysis";
    homepage = "https://www.tdhgis.com";
    id = "1tHBhEFO8ifY_DEaD8PrOlcFPiH3t-AqM";
    sha256 = "1zjcs8dhdvhisf4kws369gx94gr6xaz3k8cp12imk6adn5fw94sp";
    wxgtk = wxGTK30_gcc8;
  };

  gisnet = callPackage ./base.nix {
    pname = "TdhGISnet";
    version = "21.02.26";
    description = "Shortest Path Analysis / Route Optimization";
    homepage = "https://sites.google.com/tdhgis.com/tdhgisnet";
    id = "1G3Xtc3ZLUPCUl5t8wnzNFTrJqkhvx_MJ";
    sha256 = "129acpcrw58vqnr27zi43p922i62ganwscs6h8qj0ph13zshgqvc";
    wxgtk = wxGTK30_gcc8;
  };

  net = callPackage ./base.nix {
    pname = "TdhNet";
    version = "21.02.22";
    description = "Hydraulic Modeling for Water Distribution Systems";
    homepage = "https://www.tdhnet.com";
    id = "1ChOEF7Ew1v7qvTpJhOnvy0Nk1Y4dfne3";
    sha256 = "0mrdkrcr0fz2mk93fybyyn0z2s16f66az9vz8fi58qppbb9f4pwm";
    wxgtk = wxGTK30_gcc8;
  };
}

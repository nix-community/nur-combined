{ callPackage, wxGTK30, gcc7Stdenv }:
let
  # Fix mismatch between the program and library build versions
  wxGTK30_gcc7 = wxGTK30.override { stdenv = gcc7Stdenv; compat26 = false; };
in
{
  cad = callPackage ./base.nix {
    pname = "TdhCad";
    version = "20.09.28";
    description = "Vector Graphics and Charting";
    homepage = "https://www.tdhcad.com";
    id = "1YMbTKKQH7yULilkrr1jpxEYWkBU_qBzB";
    sha256 = "0764i3n2hb23r8bgab14p0w4qmiqj05wi43qxaz0w3wa3zzgrqsi";
    wxGTK30 = wxGTK30_gcc7;
  };

  gis = callPackage ./base.nix {
    pname = "TdhGIS";
    version = "20.08.28";
    description = "Vector Based Spatial Analysis";
    homepage = "https://www.tdhgis.com";
    id = "1T7onw2LCO4ykIGbQnm8WrbG-FIN8c_EK";
    sha256 = "0mzh53l8i44pz1xs95cr4cqhkan27y7szi6fs9xhkh3pqgjp5810";
    wxGTK30 = wxGTK30_gcc7;
  };

  gisnet = callPackage ./base.nix {
    pname = "TdhGISnet";
    version = "20.08.17";
    description = "Shortest Path Analysis / Route Optimization";
    homepage = "https://sites.google.com/tdhgis.com/tdhgisnet";
    id = "1wML0dU-bloP3dAnvhXKu0Pati4iMS5IU";
    sha256 = "014a9svb00l1km563nzizmy60k0ly517zrf5wxv3cqf16fngdlpr";
    wxGTK30 = wxGTK30_gcc7;
  };

  net = callPackage ./base.nix {
    pname = "TdhNet";
    version = "20.04.30";
    description = "Hydraulic Modeling for Water Distribution Systems";
    homepage = "https://www.tdhnet.com";
    id = "1u3sVMxDavVLUfHc0XRGUKAGNMpb7CH1K";
    sha256 = "0l9ph40gj4hk3g1zyb1bsgnkna2vhl9wwqzkvcsx2wckzxd4cmw7";
    wxGTK30 = wxGTK30_gcc7;
  };
}

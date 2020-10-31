{ stdenv, fetchFromGitHub, buildGoModule }:
with stdenv.lib;
let
  pname = "gemget";
  version = "1.6.0";
in
buildGoModule {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "makeworld-the-better-one";
    repo = pname;
    rev = "v${version}";
    sha256 = "1rwn7l56xv8pax40951wr4lkxqb9gg95xfa65h1imhncfch80anh";
  };

  nativeBuildInputs = [ stdenv ];

  vendorSha256 = "01xqslbifx2pkw82vxfnkd57gnn2957gxniqw0dy3338wcym0p07";

  buildPhase = ''
    make
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp gemget $out/bin/gemget
  '';


}

{ stdenv, fetchFromGitHub, cmake, python3 }:

stdenv.mkDerivation {
  pname = "keystone-engine-unstable";
  version = "0.9.2-rc1.post2";
  src = fetchFromGitHub {
    owner = "keystone-engine";
    repo = "keystone";
    rev = "4d060561fa7a5c8add3289aa37ee1224be98ef05";
    sha256 = "1m6avfxma6vddsrmdi3pz06jqrpk8v1gp5g2h9lb44s4ai6r8s9s";
  };

  strictDeps = true;

  nativeBuildInputs = [ cmake python3 ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  buildInputs = [ python3 ];

  meta = with stdenv.lib; {
    description = "lightweight multi-platform, multi-architecture assembler framework";
    homepage = "http://www.keystone-engine.org/";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}

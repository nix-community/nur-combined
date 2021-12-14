{ stdenv, lib, fetchgit, meson, ninja, pkgconfig, boost, gtest
, debug ? false
, withoutBoostPropagation ? false
}:

stdenv.mkDerivation rec {
  version = "1.2.0";
  name = "intervalset-${version}";

  src = fetchgit {
    url = "https://framagit.org/batsim/intervalset.git";
    rev = "v${version}";
    sha256 = "1ayj6jjznbd0kwacz6dki6yk4rxdssapmz4gd8qh1yq1z1qbjqgs";
  };

  nativeBuildInputs = [ meson ninja pkgconfig ];
  buildInputs = [ gtest ]
    ++ lib.optionals withoutBoostPropagation [ boost ];
  propagatedBuildInputs = lib.optionals (!withoutBoostPropagation) [ boost ];

  ninjaFlags = [ "-v" ];
  doCheck = true;

  mesonBuildType = if debug then "debug" else "release";
  CXXFLAGS = if debug then "-O0" else "";
  hardeningDisable = if debug then [ "fortify" ] else [];
  dontStrip = debug;

  meta = with lib; {
    description = "C++ library to manage sets of integral closed intervals";
    longDescription = ''
      intervalset is a C++ library to manage sets of closed intervals of integers.
      This is a simple wrapper around Boost.Icl.
    '';
    homepage = https://framagit.org/batsim/intervalset;
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;
  };
}

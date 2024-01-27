{ lib
, stdenv
, fetchFromGitHub
, vapoursynth
, meson
, ninja
, pkg-config
}:

stdenv.mkDerivation rec {
  pname = "vapoursynth-bwdif";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "HomeOfVapourSynthEvolution";
    repo = "VapourSynth-Bwdif";
    rev = "r${version}";
    sha256 = "sha256-wpALZMSKX+LvbPOL1DpqumfT1Ql4Kbi4Mi7U2nooZmQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    vapoursynth
  ];

  postPatch = ''
    substituteInPlace meson.build \
      --replace ", 'b_lto=true'" "" \
      --replace "vapoursynth_dep.get_variable(pkgconfig: 'libdir')" "get_option('libdir')"
  '';

  postInstall = ''
    cp libavx2.a $out/lib/vapoursynth/libavx2.a
    cp libavx512.a $out/lib/vapoursynth/libavx512.a
  '';

  meta = with lib; {
    description = "Bwdif filter for VapourSynth.";
    homepage = "https://github.com/HomeOfVapourSynthEvolution/VapourSynth-Bwdif";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    platforms = platforms.all;
  };
}

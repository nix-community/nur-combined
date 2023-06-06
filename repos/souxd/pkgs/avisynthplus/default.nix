{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, cmake
, gcc
, ninja
, git
, libdevil
, python3
}:

stdenv.mkDerivation {
  pname = "avisynthplus";
  version = "v3.7.2";

  src = fetchFromGitHub {
  	  owner = "avisynth";
	  repo = "avisynthplus";
	  rev = "7290a6f7f803a06ed31e235785d55dc68ab76d55";
	  sha256 = "xZ00JXub2lKuqd5ZaRA6/839YeeC0muFhmSMG9/T/6k=";
        };

  nativeBuildInputs = [
    cmake
    gcc
    ninja
    (python3.withPackages (ps: [ ps.sphinx ]))
    pkg-config
  ];

  buildInputs = [ git libdevil ];

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    mkdir $src/avisynth-build && \
    cd $src/avisynth-build && \

    cmake $src -G Ninja && \
    ninja
  '';

  installPhase = ''
    mkdir -p $out
    cp -r -t $out {avs_core,plugins}
  '';

  meta = with lib; {
    description = "AviSynth with improvements";
    homepage = "http://avs-plus.net/";
    license = licenses.gpl2;
    platforms = platforms.linux;
    broken = true;
  };
}

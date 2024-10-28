{
  fetchFromGitHub,
  lib,
  makeWrapper,
  stdenv,
  cmake,
  pkg-config,
  wget,
  jsoncpp,
  glog,
  cbmc,
  gurobi,
}:
stdenv.mkDerivation rec {
  name = "AutoLifter";
  version = "1.0.0";
  src =
    fetchFromGitHub
    {
      owner = "jiry17";
      repo = "AutoLifter";
      rev = "4eef4cba765c6ee3687106b25c167bcd79441332";
      sha256 = "bEAWVa0xYxtaPHGrpGNRBWey4rnJfRdpeYAaSKaoIPc=";
    };
  patches = [./diff.patch];

  nativeBuildInputs = [
    cmake
    pkg-config
    wget
    jsoncpp
    glog
    cbmc
    makeWrapper
    gurobi
  ];

  preConfigure = ''
    substituteInPlace basic/config.cpp run/run run/run_exp \
      --replace 'SOURCEPATH' $out

    substituteInPlace exp/paradigms/paradigm_util.cpp \
      --replace 'command = "cbmc "' 'command = "${cbmc}/bin/cbmc "'

    substituteInPlace run/run run/run_exp \
      --replace 'build/main' 'bin/autolifter_main'
  '';
  cmakeBuildType = " ";

  installPhase = ''
    mkdir -p $out/bin
    cp main $out/bin/autolifter_main
    cp -r ../run $out
    cp -r ../resource $out

    makeWrapper $out/run/run $out/bin/autolifter_run --argv0 "run"
    makeWrapper $out/run/run_exp $out/bin/autolifter_run_exp --argv0 "run"
  '';

  meta = with lib; {
    description = "Artifact for TOPLAS24: Decomposition-Based Synthesis for Applying D&C-Like Algorithmic Paradigms";
    homepage = "https://github.com/jiry17/AutoLifter";
    license = licenses.unfreeRedistributable;
    platforms = ["x86_64-linux"];
  };
}

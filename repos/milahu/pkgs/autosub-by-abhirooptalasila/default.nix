/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
./result/bin/srtgen
*/

{
  pkgs ? import <nixpkgs> {}
}:

let
  /*
  pkgs = import (builtins.fetchTarball {
    name = "nixpkgs-unstable-2022-03-03";
    url = "https://github.com/nixos/nixpkgs/archive/7a3e6d6604ad99c77e7a98943734bdeea564bff2.tar.gz";
    sha256 = "1vzrxcgkfaip6jfmgjjahxm3b80sv89608d920rzikcq71wvjiaz";
  }) {};
  */

  python = pkgs.python39; # limited by deepspeech which is only available for python 3.9
  # https://discourse.mozilla.org/t/cp310-binary-release/94269

  buildPythonPackage = python.pkgs.buildPythonPackage;
  fetchPypi = python.pkgs.fetchPypi;
  lib = pkgs.lib;
  fetchFromGitHub = pkgs.fetchFromGitHub;

  #tensorflow = pkgs.tensorflow;

  extraPythonPackages = rec {

    numba_py39 = python.pkgs.callPackage ./nix/numba {};
    optuna = python.pkgs.callPackage ./nix/optuna { inherit keras; };
    # optuna is marked as broken https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/python-modules/optuna/default.nix
    keras = python.pkgs.callPackage ./nix/keras { };
    tensorflow = (python.pkgs.callPackage ./nix/tensorflow/bin.nix {
      tensorflow-tensorboard = python.pkgs.callPackage ./nix/tensorflow-tensorboard {};
      tensorflow-estimator = python.pkgs.callPackage ./nix/tensorflow-estimator {};
    });
    SpeechRecognition = python.pkgs.callPackage ./nix/speechrecognition {};
    pocketsphinx = python.pkgs.callPackage ./nix/pocketsphinx {};
    stt = python.pkgs.callPackage ./nix/stt {
      inherit pyogg_0_6_14a1 webdataset optuna;
      numba = numba_py39;
    };
    pyogg_0_6_14a1 = python.pkgs.callPackage ./nix/pyogg {};
    webdataset = python.pkgs.callPackage ./nix/webdataset {};
    ds_ctcdecoder = python.pkgs.callPackage ./nix/ds-ctcdecoder {};
    deepspeech = python.pkgs.callPackage ./nix/deepspeech {
      inherit tensorflow ds_ctcdecoder;
      numba = numba_py39;
    };
  };

in

buildPythonPackage rec {
  pname = "autosub";
  version = "1.1.0";
  src = fetchFromGitHub {
    owner = "milahu";
    repo = "AutoSub";
    rev = "76725b98bf7cae5bb3f5d3d240f944b25ff14903";
    sha256 = "fTf4x3gFf01UtV7y0mgUJAOzxQqBJMH+ppT36BtmttI=";
  };
  /*
  src = fetchFromGitHub {
    # https://github.com/abhirooptalasila/AutoSub
    owner = "abhirooptalasila";
    repo = "AutoSub";
    rev = "todo";
    sha256 = ""; # todo
  };
  */
  # relax requirements
  preBuild = ''
    sed -i 's/==.*$//' requirements.txt
  '';
  propagatedBuildInputs = with python.pkgs; [
    pydub
    kiwisolver
    pyparsing
    scikit-learn
    tqdm
    extraPythonPackages.stt
    extraPythonPackages.deepspeech
    extraPythonPackages.SpeechRecognition
    extraPythonPackages.pocketsphinx
  ];
  meta = with lib; {
    homepage = "https://github.com/abhirooptalasila/AutoSub";
    description = "generate subtitle files (SRT/VTT/TXT) for any video using DeepSpeech or Coqui";
    license = licenses.mit;
  };
}

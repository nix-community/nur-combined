{ stdenv, lib, buildPythonPackage, fetchPypi, scipy, scikitlearn, numpy
, matplotlib, ipywidgets, plyfile, pandas, pyyaml, tqdm, tree, unzip, zip
, autoPatchelfHook, pytorchWithCuda, libtensorflow-bin, libusb, cudaPackages
, libGL }:

let
  addict = buildPythonPackage {
    pname = "addict";
    version = "2.4.0";

    src = fetchPypi {
      pname = "addict";
      version = "2.4.0";
      sha256 = "1574sicy5ydx9pvva3lbx8qp56z9jbdwbj26aqgjhyh61q723cmk";
    };
  };

in buildPythonPackage rec {
  pname = "open3d";
  version = "0.13.0";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "cp38";
    python = "cp38";
    abi = "cp38";
    platform = "manylinux2014_x86_64";
    sha256 = "sha256:1526gvfrnvxfla5ji2rhjgdqq20h1i68v5673lssh087y2pdh8ys";
  };

  # sklearn dependency does not exist ofc... Why can't people
  # package their shit normally. This tilts me so much.
  patchPhase = ''
    ${unzip}/bin/unzip ./dist/open3d-0.12.0-cp37-cp37m-manylinux2014_x86_64.whl -d tmp
    rm ./dist/open3d-0.12.0-cp37-cp37m-manylinux2014_x86_64.whl
    sed -i 's/sklearn/scikit-learn/g' tmp/open3d-0.12.0.dist-info/METADATA
    cd tmp
    ${zip}/bin/zip -0 -r ../dist/open3d-0.12.0-cp37-cp37m-manylinux2014_x86_64.whl ./*
    cd ../
  '';

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    # so deps
    stdenv.cc.cc.lib
    libusb.out
    pytorchWithCuda
    libtensorflow-bin
    cudaPackages.cudatoolkit_10_1.lib
    libGL
  ];

  propagatedBuildInputs = [
    # py deps
    ipywidgets
    tqdm
    pyyaml
    pandas
    plyfile
    scipy
    scikitlearn
    numpy
    addict
    matplotlib
  ];
}

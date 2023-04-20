{ lib
, buildPythonPackage
, fetchPypi
, rustPlatform
, setuptools
, setuptools-rust
, wheel
, black
, click
, flake8
, flax
, h5py
, huggingface-hub
, isort
, jax
, numpy
, paddlepaddle ? null
, pytest
, pytest-benchmark
, tensorflow
, torch
}:

buildPythonPackage rec {
  pname = "safetensors";
  version = "0.3.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-W+iy/M3GrshMnWcyGAV1/hujr8VZy+luIwHqzEXFuaY=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
    setuptools
    setuptools-rust
    wheel
  ];

  passthru.optional-dependencies = {
    all = [
      black
      click
      flake8
      flax
      h5py
      huggingface-hub
      isort
      jax
      numpy
      paddlepaddle
      pytest
      pytest-benchmark
      setuptools-rust
      tensorflow
      torch
    ];
    dev = [
      black
      click
      flake8
      flax
      h5py
      huggingface-hub
      isort
      jax
      numpy
      paddlepaddle
      pytest
      pytest-benchmark
      setuptools-rust
      tensorflow
      torch
    ];
    jax = [
      flax
      jax
    ];
    numpy = [
      numpy
    ];
    paddlepaddle = [
      paddlepaddle
    ];
    quality = [
      black
      click
      flake8
      isort
    ];
    tensorflow = [
      tensorflow
    ];
    testing = [
      h5py
      huggingface-hub
      numpy
      pytest
      pytest-benchmark
      setuptools-rust
    ];
    torch = [
      torch
    ];
  };

  pythonImportsCheck = [ "safetensors" ];

  meta = with lib; {
    description = "Fast and Safe Tensor serialization";
    homepage = "https://pypi.org/project/safetensors/";
    license = with licenses; [ ];
    maintainers = with maintainers; [ ];
  };
}

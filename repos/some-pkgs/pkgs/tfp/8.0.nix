{ lib
, fetchFromGitHub
, fetchpatch
, bazel_3
, buildBazelPackage
, buildPythonPackage
, python
, setuptools
, wheel
, absl-py
, tensorflow
, six
, numpy
, decorator
, cloudpickle
, gast
, hypothesis
, scipy
, matplotlib
, mock
, pytest
, jax
, dm-tree
, stdenv
}:

let
  version = "0.13.0";
  pname = "tensorflow_probability";

  # first build all binaries and generate setup.py using bazel
  bazel-wheel = buildBazelPackage {
    name = "${pname}-${version}-py2.py3-none-any.whl";

    src = fetchFromGitHub {
      owner = "tensorflow";
      repo = "probability";
      rev = "v${version}";
      sha256 = "sha256-o+l0kHLIk1BVYDNRww15cW1+FxYBDMBZ8fm4UtJsBMk=";
    };

    nativeBuildInputs = [
      # needed to create the output wheel in installPhase
      python
      setuptools
      wheel
      absl-py
      tensorflow
    ];

    bazelTarget = ":pip_pkg";

    fetchAttrs = {
      sha256 = "sha256-1X00azKc3Me6RM7xkM9CB1aNZF4bBDqKb76NXjht/Wk=";
    };

    buildAttrs = {
      preBuild = ''
        patchShebangs .
      '';

      installPhase = ''
        # work around timestamp issues
        # https://github.com/NixOS/nixpkgs/issues/270#issuecomment-467583872
        export SOURCE_DATE_EPOCH=315532800

        # First build, then move. Otherwise pip_pkg would create the dir $out
        # and then put the wheel in that directory. However we want $out to
        # point directly to the wheel file.
        ./bazel-bin/pip_pkg . --release
        mv *.whl "$out"
      '';
    };

    meta.broken = stdenv.isDarwin;
  };
in
buildPythonPackage {
  inherit version pname;
  format = "wheel";

  src = bazel-wheel;

  buildInputs = [
    jax
    tensorflow
  ];
  propagatedBuildInputs = [
    six
    numpy
    decorator
    cloudpickle
    gast
    dm-tree
  ];

  # Listed here:
  # https://github.com/tensorflow/probability/blob/f01d27a6f256430f03b14beb14d37def726cb257/testing/run_tests.sh#L58
  checkInputs = [
    hypothesis
    pytest
    scipy
    matplotlib
    mock
  ];

  # actual checks currently fail because for some reason
  # tf.enable_eager_execution is called too late. Probably because upstream
  # intents these tests to be run by bazel, not plain pytest.
  # checkPhase = ''
  #   # tests need to import from other test files
  #   export PYTHONPATH="$PWD/tensorflow-probability:$PYTHONPATH"
  #   py.test
  # '';

  # sanity check
  checkPhase = ''
    python -c 'import tensorflow_probability'
  '';

  meta = with lib; {
    broken = false;
    description = "Library for probabilistic reasoning and statistical analysis";
    homepage = "https://www.tensorflow.org/probability/";
    license = licenses.asl20;
    maintainers = with maintainers; [ ]; # This package is maintainerless.
  };
}

{ lib
, buildPythonPackage
, fetchPypi
, setuptools-scm
, setuptools-scm-git-archive
, pyyaml
, packaging
, pytestCheckHook
, flaky
, pytest-mock
, ansible
, subprocess-tee
}:

buildPythonPackage rec {
  pname = "ansible-compat";
  version = "1.0.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    sha256 = "193hz44inajcicr5q81k0d40b35wjbz2ls1cc3mqx1nps75jmpia";
  };

  nativeBuildInputs = [
    setuptools-scm
    setuptools-scm-git-archive
    ansible
  ];

  propagatedBuildInputs = [
    pyyaml
    packaging
    subprocess-tee
  ];

  checkInputs = [
    pytestCheckHook
    pytest-mock
    flaky
  ];

  disabledTests = [
    # tests requiring an internet connection
    "test_prerun_reqs_v2"
    "test_require_collection_wrong_version"
    "test_require_collection"
    "test_install_collection"
    "test_install_collection_dest"
    "test_upgrade_collection"
    "test_require_collection_no_cache_dir"
    "test_runtime_example"
    "test_prepare_environment_with_collections"
    "test_prerun_reqs_v1"
  ];

  preCheck = ''
    # needed to run ansible-config
    export HOME=$PWD
    # fix test failing without our PATH
    sed -i 's/\(env={.\+}\)/\1 | os.environ/' test/test_runtime.py
  '';
}

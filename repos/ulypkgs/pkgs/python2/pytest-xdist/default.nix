{
  lib,
  fetchPypi,
  buildPythonPackage,
  execnet,
  pytest,
  setuptools-scm,
  pytest-forked,
  filelock,
  psutil,
  six,
  isPy3k,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytest-xdist";
  version = "1.34.0";
  format = "setuptools";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-NA6Og+KkwNhhvdjQXF17cUP27qCrqQKZfbFcKoa+BO4=";
  };

  nativeBuildInputs = [
    setuptools-scm
    pytest
  ];
  nativeCheckInputs = [
    pytest
    filelock
  ];
  propagatedBuildInputs = [
    execnet
    pytest-forked
    psutil
    six
  ];

  # Encountered a memory leak
  # https://github.com/pytest-dev/pytest-xdist/issues/462
  doCheck = !isPy3k;

  checkPhase = ''
    # Excluded tests access file system
    py.test testing -k "not test_distribution_rsyncdirs_example \
                    and not test_rsync_popen_with_path \
                    and not test_popen_rsync_subdir \
                    and not test_init_rsync_roots \
                    and not test_rsyncignore"
  '';

  meta = {
    description = "py.test xdist plugin for distributed testing and loop-on-failing modes";
    homepage = "https://github.com/pytest-dev/pytest-xdist";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})

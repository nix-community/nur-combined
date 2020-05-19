{ lib
, buildPythonPackage
, pythonOlder
, pythonAtLeast
, isPy37
, isPy38
, fetchFromGitHub
, fetchPypi
  # Check inputs
, pytestCheckHook
}:

let
  rx-version = "0.3.4";
  wheel-args = if isPy37 then
      { python = "cp37"; sha256 = "1hfrdj8svkfdraa299gcj18a601l4zn646fkgq7m56brpagssf9l"; }
    else if isPy38 then
      { python = "cp38"; sha256 = "383ec97b7142858bb6442945d72ce5ca9601ceba015c764d210b"; }
    else throw "python version & hash not included. Override attribute `wheel-args` with version & hash at https://pypi.org/project/retworkx";

  github-source = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = rx-version;
    sha256 = "0cd3x64y49q9a3jrkiknlfkiccxkxgl624x5pqk7gm34s1lnzl8h";
  };
in
buildPythonPackage rec {
  pname = "retworkx";
  version = rx-version;
  format = "wheel";

  disabled = pythonOlder "3.5" || pythonAtLeast "3.9"; # compiled versions only included for 3.5 <= py <= 3.8

  src = fetchPypi {
    inherit pname version format;
    inherit (wheel-args) python sha256;
    abi = if pythonOlder "3.8" then "${wheel-args.python}m" else wheel-args.python;
    platform = "manylinux2010_x86_64"; # i686, aarch64, and ppc64 also available, restricting to x86 for simplicity
  };

  pythonImportsCheck = [ "retworkx" ];

  checkInputs = [ pytestCheckHook ];
  preCheck = ''
    pushd $(mktemp -d)
    cp -r ${github-source}/$sourceRoot/tests .
  '';
  postCheck = "popd";

  meta = with lib; {
    description = "A python graph library implemented in Rust.";
    homepage = "https://retworkx.readthedocs.io/en/latest/index.html";
    downloadPage = "https://github.com/Qiskit/retworkx/releases";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
    platforms = platforms.x86_64;
  };
}

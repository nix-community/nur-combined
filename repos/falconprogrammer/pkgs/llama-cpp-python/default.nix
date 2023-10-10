{ buildPythonPackage
, fetchFromGitHub
, fetchPypi
, lib
, stdenv
, darwin
, cmake
, diskcache
, ninja
, numpy
, pathspec
, poetry-core
, pyproject-metadata
, scikit-build-core
, setuptools
, typing-extensions
, python-ver
}:
let
  inherit (stdenv) isDarwin;
  osSpecific = with darwin.apple_sdk.frameworks; if isDarwin then [ Accelerate CoreGraphics CoreVideo ] else [ ];
  llama-cpp-pin = fetchFromGitHub {
    owner = "ggerganov";
    repo = "llama.cpp";
    rev = "48edda30ee545fdac2e7a33d505382888f748bbf";
    hash = "sha256-iUQ3eLI/nTXOkbjgx1CT9iN1k1cncgMKcReUpiT+1Yg=";
  };

	scikit-build-core-mod = scikit-build-core.overrideAttrs(old: rec {
		version = "0.5.1";
		src = fetchPypi {
			pname = "scikit_build_core";
			inherit version;
			hash = "sha256-xtrVpRJ7Kr+qI8uR0jrCEFn9d83fcSKzP9B3kQJNz78=";
		};
	});

in
buildPythonPackage rec {
  pname = "llama-cpp-python";
  version = "0.2.11";

  format = "pyproject";
  src = fetchFromGitHub {
    owner = "abetlen";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-tZN771XhUq+P6REG0n2hd+9CyK3KG+lC26OdavJNWnk=";
  };

  preConfigure = ''
    cp -r ${llama-cpp-pin}/. ./vendor/llama.cpp
    chmod -R +w ./vendor/llama.cpp
  '';
  preBuild = ''
    cd ..
  '';
  buildInputs = osSpecific;

  nativeBuildInputs = [
    cmake
    ninja
    poetry-core
    scikit-build-core-mod
    setuptools
  ];

  propagatedBuildInputs = [
    typing-extensions
	diskcache
	pathspec
	pyproject-metadata
	numpy
  ];

  pythonImportsCheck = [ "llama_cpp" ];

  meta = with lib; {
    description = "A Python wrapper for llama.cpp";
    homepage = "https://github.com/abetlen/llama-cpp-python";
    license = licenses.mit;
  };
}

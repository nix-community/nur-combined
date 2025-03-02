{
  # lib
  lib
, fetchFromGitHub
, # python
  buildPythonPackage
, ...
}: buildPythonPackage rec {
  pname = "gputil";
  version = "1.4.0-py3.12";
  src = fetchFromGitHub {
    owner = "mathoudebine";
    repo = "gputil";
    rev = version;
    hash = "sha256-pIol5PVDYOJ8Eb8yA2km7jXGdYE4OqCjBNs2f+a505s=";
  };

  meta = {
    homepage = "https://github.com/mathoudebine/gputil";
    description = "Python module for getting the GPU status from NVIDIA GPUs using `nvidia-smi`. This is patched version to work with Python 3.12.";
    license = with lib.licenses; [ mit ];
    platforms = [ "x86_64-linux" ];
  };
}

{ lib
, python3Packages
, fetchFromGitHub
, indexedproperty
}:

python3Packages.buildPythonPackage rec {
  pname = "RsWaveform";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "Rohde-Schwarz";
    repo = "RsWaveform";
    rev = version;
    sha256 = "sha256-U7bqCMoe5TrAFFoiVtPMSJisJ8YUTOlrGYOX12dShsg=";
  };

  propagatedBuildInputs = with python3Packages; [
    setuptools-scm
    numpy
    indexedproperty
  ];
  buildInputs = with python3Packages; [ setuptools ];
  pyproject = true;
  # format = "setuptools";

  # doCheck = false;

  meta = with lib; {
    description = ''Convenient and easy-to-use software solution for creating and modifying waveform files that can be used with Rohde & Schwarz instruments, but it does not provide access to encrypted waveform files that require a license'';
    homepage = "https://github.com/Rohde-Schwarz/RsWaveform";
    license = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

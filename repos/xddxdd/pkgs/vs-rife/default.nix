{ lib
, fetchFromGitHub
, python3Packages
, vapoursynth
, ...
} @ args:

with python3Packages;

buildPythonPackage rec {
  pname = "vs-rife";
  version = "v2.0.0";

  src = fetchFromGitHub {
    owner = "HolyWu";
    repo = pname;
    rev = version;
    sha256 = "sha256-mfEh1mHXHVT97vQ5+qur2RkvXRi6kdeny7Cdnf4VfRE=";
  };

  preBuild = ''
    cat >setup.py <<EOF
    import setuptools

    if __name__ == "__main__":
      setuptools.setup()
    EOF

    sed -i '/VapourSynth/d' setup.cfg
  '';

  doCheck = false;

  propagatedBuildInputs = [ setuptools pytorch numpy ];

  meta = with lib; {
    description = "Real-Time Intermediate Flow Estimation for Video Frame Interpolation for VapourSynth";
    homepage = "https://github.com/HolyWu/vs-rife";
    license = licenses.mit;
  };
}

{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "trinity";
  version = "d295fa4034e1ba1880e143c1356d80f0332885e1";

  src = fetchFromGitHub {
    owner = "kernelslacker";
    repo = "trinity";
    rev = "${version}";
    sha256 = "ykTCWvxm2JOV+pIfk8VmsoBQBM6Pe1zEHzTkFOKSHxY=";
  };

  postPatch = ''
    patchShebangs configure
    patchShebangs scripts
  '';

  enableParallelBuilding = true;

  makeFlags = [ "DESTDIR=$(out)" ];

  meta = with lib; {
    description = "A Linux System call fuzz tester";
    homepage = "https://codemonkey.org.uk/projects/trinity/";
    license = licenses.gpl2;
    maintainers = [ maintainers.dezgeg ];
    platforms = platforms.linux;
  };
}

{ stdenv, fetchFromGitHub, lib, ... }:

stdenv.mkDerivation rec {
  pname = "tbsm";
  version = "v0.5";

  src = fetchFromGitHub {
    owner = "loh-tar";
    repo = "tbsm";
    rev = version;
    sha256 = "166f8awqsc27a20rvvv5vp8yhkq3s3d03msd9zkxxx091cnd4va0";
    # fetchSubmodules = true;
  };
  # buildPhase = ''
  #   make
  # '';
  makeFlags = [ "DESTDIR=$(out)" ];
  postInstall = ''
    mv $out/usr/* $out/
    rmdir $out/usr
  '';

  meta = with lib; {
    description = "TUI display manager";
    license = licenses.wtfpl;
    homepage = "https://github.com/loh-tar/tbsm";
    maintainers = [ maintainers.spacekookie ];
  };
}

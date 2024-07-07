{ lib
, fetchFromGitHub
, fetchpatch
, python3
, python3Packages ? python3.pkgs
}:
python3Packages.buildPythonPackage rec {
  pname = "youtube-dl";
  version = "2024-07-06";

  src = fetchFromGitHub {
    owner = "ytdl-org";
    repo = "youtube-dl";
    rev = "211cbfd5d46025a8e4d8f9f3d424aaada4698974";
    sha256 = "sha256-ktH1tzS9MZpo9uT9JdJs5gqNMHR7z5p0xRG9PkXr6ao=";
  };

  doCheck = false;

  meta = with lib; {
    description = "Command-line program to download videos from YouTube.com";
    homepage = "http://ytdl-org.github.io/youtube-dl/";
    license = licenses.unlicense;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

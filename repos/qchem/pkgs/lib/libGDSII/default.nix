{ lib, stdenv, fetchFromGitHub, autoreconfHook } :

stdenv.mkDerivation rec {
  pname = "libGDSII";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "HomerReid";
    repo = pname;
    rev = "v${version}";
    sha256 = "0vgxvm04bqaqcgh5h2ar622rscrqym80wi1pfh0xfymxbvp2sw8i";
  };

  # File is missing in the repo but automake requires it.
  postPatch = ''
    touch ChangeLog
  '';

  nativeBuildInputs = [ autoreconfHook ];


  meta = with lib; {
    description = "Library and command-line utility for reading GDSII geometry files";
    homepage = "https://github.com/HomerReid/libGDSII";
    license = with licenses; [ gpl2Only ];
    maintainers = [ maintainers.sheepforce ];
    platforms = platforms.linux;
  };
}

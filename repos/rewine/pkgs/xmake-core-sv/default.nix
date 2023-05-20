{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
}:

stdenv.mkDerivation rec {
  pname = "xmake-core-sv";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "xmake-io";
    repo = pname;
    rev = "10ee6a807466a5e61309201caea360a113ad3862";
    hash = "sha256-icvGQi6FNSZXNGs2oLiUKu6rrVsWcXh1r91kycGjnwY=";
    #"v${version}";
    #hash = "sha256-rbIVFOrveLbHrCIfbXtu8SG1Z8dT5vOldy4ucZb7p24=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  meta = with lib; {
    description = "Public domain cross-platform semantic versioning in c99";
    homepage = "https://github.com/xmake-io/xmake-core-sv";
    license = licenses.unlicense;
    platforms = platforms.linux;
    maintainers = with maintainers; [ rewine ];
  };
}


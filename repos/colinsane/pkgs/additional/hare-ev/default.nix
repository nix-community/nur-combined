{ stdenv
, lib
, fetchFromSourcehut
, hare
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "hare-ev";
  version = "unstable-2022-12-29";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "c585f01f4d13a25edb62477c07fdf32451417fee";
    hash = "sha256-lB+ZPKGeYASV9oCE5iyDUCCPu2V07hqMXEktIY4fn1E=";
  };

  nativeBuildInputs = [
    hare
  ];

  installFlags = [ "PREFIX=" "DESTDIR=$(out)" ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "an event loop for Hare programs";
    homepage = "https://sr.ht/~sircmpwn/hare-ev";
    license = licenses.mpl20;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}

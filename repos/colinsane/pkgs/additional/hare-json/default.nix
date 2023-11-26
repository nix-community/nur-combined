{ stdenv
, lib
, fetchFromSourcehut
, hare
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "hare-json";
  version = "unstable-2023-09-21";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "e24e5dceb8628ff569338e6c4fdba35a5017c5e2";
    hash = "sha256-7QRieokqXarKwLfZynS8Rum9JV9hcxod00BWAUwwliM=";
  };

  nativeBuildInputs = [
    hare
  ];

  installFlags = [ "PREFIX=" "DESTDIR=$(out)" ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "JSON support for the Hare programming language";
    homepage = "https://sr.ht/~sircmpwn/hare-json";
    license = licenses.mpl20;
    maintainers = with maintainers; [ colinsane ];
    platforms = platforms.linux;
  };
}

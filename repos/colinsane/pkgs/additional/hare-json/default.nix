{ stdenv
, lib
, fetchFromSourcehut
, hare
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "hare-json";
  version = "unstable-2023-01-31";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "99ae40eacc19253495949301000372adf8c3f504";
    hash = "sha256-H5XKExs7e60PHmIS7TgBwG9e46Hj2M4D245vKag0ANA=";
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

{ stdenv
, lib
, fetchFromSourcehut
, hare
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "hare-ev";
  version = "unstable-2023-10-30";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = pname;
    rev = "9bdbd02401334b7d762131a46e64ca2cd24846dc";
    hash = "sha256-VY8nsy5kLDMScA2ig3Rgbkf6VQlCTnGWjzGvsI9OcaQ=";
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

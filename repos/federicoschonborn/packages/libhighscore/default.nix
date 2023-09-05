{ lib
, stdenv
, fetchFromGitLab
, gobject-introspection
, meson
, ninja
, pkg-config
, vala
}:

stdenv.mkDerivation {
  pname = "libhighscore";
  version = "unstable-2023-09-05";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "alicem";
    repo = "libhighscore";
    rev = "6e88527335cc6f78cd78087f0c937ec904aab40b";
    hash = "sha256-tNqpzTj588D1PKlseBz9y4Ad8bcsq9JaGJXsf4bWn7U=";
  };

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [
  ];

  meta = with lib; {
    description = "";
    homepage = "https://gitlab.gnome.org/alicem/libhighscore";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ federicoschonborn ];
  };
}

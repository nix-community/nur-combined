{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  pango,
  cairo,
  glib,
}:

rustPlatform.buildRustPackage rec {
  pname = "i3bar-river";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "MaxVerevkin";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-eWEcgRmoCoKkHl05vhONTOi7kboeXFS9d4capEehBGY=";
  };

  cargoHash = "sha256-JVY1pE7+uRfEGATuM95YDJM4JgJxx656Cdo5XzPWlVw=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ glib cairo pango ];

  strictDeps = true;

  meta = with lib; {
    description = "A port of i3bar for river.";
    homepage = "https://github.com/MaxVerevkin/i3bar-river";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}

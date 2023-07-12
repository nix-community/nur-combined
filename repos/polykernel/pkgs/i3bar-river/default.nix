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
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "MaxVerevkin";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FzxsIwk7iBVLG463dNnw77FMmr2tkrvdW6FOvoEbN6w=";
  };

  cargoHash = "sha256-MFuQSCiGzCthwOPweVF3elmCnUQmxffiAcSTmNrp3ms=";

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

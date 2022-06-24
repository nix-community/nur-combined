{ lib, stdenv, fetchFromGitHub, autoreconfHook, pkg-config, cairo, librsvg
, Foundation, memstreamHook
}:

stdenv.mkDerivation rec {
  pname = "smrender";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "rahra";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-b9xuOPLxA9zZzIwWl+FTSW5XHgJ2sFoC578ZH6iwjaM=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ cairo librsvg ]
    ++ lib.optionals stdenv.isDarwin [ Foundation memstreamHook ];

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/smrender -v | grep ${version} > /dev/null
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "A powerful, flexible, and modular rule-based rendering engine for OSM data";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

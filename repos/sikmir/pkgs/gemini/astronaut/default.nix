{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "astronaut";
  version = "2021-07-13";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "bf35dae0a2b4729a61372e06dc03a92ad0ff6525";
    hash = "sha256-YZaqs98QJbGJGogWoGhzzGmiJiYYIJcdn44Zufyi37E=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-p7wX1GSQ2uUyn8beXAtjd33lLsbQ5oI+UmtoNHutziM=";

  installPhase = ''
    runHook preInstall
    make PREFIX=$out install
    runHook postInstall
  '';

  meta = with lib; {
    description = "A Gemini browser for the terminal";
    inherit (src.meta) homepage;
    license = licenses.gpl3Only;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

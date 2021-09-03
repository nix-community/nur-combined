{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "astronaut";
  version = "0.1.0-rc.2";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = version;
    hash = "sha256-VI+JI7tqS2FHO9pIGAEGqV6oocYH9A/jDsjw9yYbx3k=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-6zf+BdI/3iAlip1Uu2YbZ8dyfTYQlvPi/RmMm3x3BUs=";

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

{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "astronaut";
  version = "2021-08-13";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "28d3aac526f0207933533f2b51f512ed0cfb30ab";
    hash = "sha256-yzv0mEtOr+72rrVikGjqB64M6nww5UKGXDmf/Z7XSpU=";
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

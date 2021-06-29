{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "astronaut";
  version = "2021-06-28";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "d257518c8b7280256ccd062f78ffb2638098b978";
    hash = "sha256-Hq8jJzLdM0h/0X7WIiLnSlQn996F0X2rGBFI167D+IY=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-o5BxL2azzfKhwG1lOxHe6HZUci96+jddPwq+jIJELls=";

  buildPhase = ''
    runHook preBuild
    # we use make instead of go build
    runHook postBuild
  '';

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

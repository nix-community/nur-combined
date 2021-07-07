{ lib, buildGoModule, fetchFromSourcehut, scdoc }:

buildGoModule rec {
  pname = "astronaut";
  version = "2021-07-04";

  src = fetchFromSourcehut {
    owner = "~adnano";
    repo = pname;
    rev = "85f5f440d28187a1c55b703f6575f129b7437873";
    hash = "sha256-Lt67XU0FoGsQ59b/byxqMd8014tstt6HysIi50IW4Zw=";
  };

  nativeBuildInputs = [ scdoc ];

  vendorSha256 = "sha256-o5BxL2azzfKhwG1lOxHe6HZUci96+jddPwq+jIJELls=";

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

{ lib
, stdenv
, fetchFromGitHub
, hidapi
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gloriousctl";
  version = "0-unstable-2022-06-21";

  src = fetchFromGitHub {
    owner = "enkore";
    repo = "gloriousctl";
    rev = "c968050e951f6c4d12c07f3b6551c072f7c72a0a";
    hash = "sha256-69yRab0Mx6elwkvxpmAWeaQEDTl5jBObUnoPlh0Jba0=";
  };

  buildInputs = [
    hidapi
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 gloriousctl $out/bin/gloriousctl
    runHook postInstall
  '';

  meta = {
    description = "A utility to adjust the settings of Model O/D mice on Linux/BSD";
    homepage = "https://github.com/enkore/gloriousctl";
    license = lib.licenses.eupl12;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    mainProgram = "gloriousctl";
    platforms = lib.platforms.all;
  };
})

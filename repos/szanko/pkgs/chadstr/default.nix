{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chadstr";
  version = "unstable-2022-07-05";

  src = fetchFromGitHub {
    owner = "skullchap";
    repo = "chadstr";
    rev = "6ff6ea85bbf89f0d765d3dac8e8cd4eb969c9979";
    hash = "sha256-XigchUqdjoB8Dx830haMOftBQwrfO2NU2lC8oWkfLKk=";
  };


  installPhase = ''
    runHook preInstall

    mkdir -p $out/include
    cp chadstr.h $out/include/chadstr.h

    runHook postInstall
    '';

  meta = {
    description = "Chad Strings - The Chad way to handle strings in C";
    homepage = "https://github.com/skullchap/chadstr";
    license = lib.licenses.gpl3Only;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
})

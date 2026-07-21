{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "bof4-text-extractor";
  version = "unstable-2022-11-28";

  src = fetchFromGitHub {
    owner = "glitch-in-the-herring";
    repo = "bof4-text-extractor";
    rev = "a8abb3ac459c12e9d31cc9aa34e1f86ccb8456dc";
    hash = "sha256-0Ryih0kQwzlUuYs3LUU/Q4s2IK7cF850wQWCnJp+ch8=";
  };

  patches = [
    ./patches/0001-fix-is_zenny_position-undeclared-buffer.patch
  ];

  buildPhase = ''
    runHook preBuild

    gcc -O2 -o extractor src/extractor.c src/utils.c
    gcc -O2 -o jpextractor src/jpextractor.c src/jputils.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp extractor jpextractor $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Text extractor for Breath of Fire IV";
    longDescription = ''
      A tool to extract the dialogue sections from AREAxxx.EMI files found in
      Breath of Fire IV's game files. Supports both English and Japanese text
      extraction.
    '';
    homepage = "https://github.com/glitch-in-the-herring/bof4-text-extractor";
    license = licenses.mit;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "extractor";
  };
}

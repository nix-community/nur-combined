{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
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
    ./patches/0002-add-data-dir-env-var.patch
  ];

  patchFlags = [
    "-p1"
    "--ignore-whitespace"
  ];

  nativeBuildInputs = [
    makeWrapper
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
    cp extractor $out/bin/bof4-extractor
    cp jpextractor $out/bin/bof4-jpextractor

    # Install .src data files (lookup tables)
    mkdir -p $out/share/bof4-text-extractor
    cp *.src $out/share/bof4-text-extractor/

    # Patch mass_extract.py to use the prefixed binary names
    sed -i 's/"jpextractor.exe"/"bof4-jpextractor"/g; s/"extractor.exe"/"bof4-extractor"/g' mass_extract.py

    # Install Python scripts with bof4- prefix
    # The original scripts lack shebangs, so add them before installing
    sed -i '1i#!/usr/bin/env python3' mass_extract.py deduplicator.py
    install -m755 mass_extract.py $out/bin/bof4-mass-extract
    install -m755 deduplicator.py $out/bin/bof4-deduplicator
    patchShebangs $out/bin/bof4-mass-extract $out/bin/bof4-deduplicator

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/bof4-jpextractor --set BOF4_DATA_DIR $out/share/bof4-text-extractor
    wrapProgram $out/bin/bof4-extractor --set BOF4_DATA_DIR $out/share/bof4-text-extractor
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
    mainProgram = "bof4-extractor";
  };
}

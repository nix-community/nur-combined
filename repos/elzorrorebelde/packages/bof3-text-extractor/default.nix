{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "bof3-text-extractor";
  version = "unstable-2022-11-30";

  src = fetchFromGitHub {
    owner = "glitch-in-the-herring";
    repo = "bof3-text-extractor";
    rev = "ce0d75f61c0240ffe2afa65ecd66a4052bb50942";
    hash = "sha256-bJMOJ6I7zqFeilMmJ+Oy11nWpdVXGoYiQe8ZRgCL1zY=";
  };

  patches = [
    ./patches/0001-add-data-dir-env-var.patch
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

    gcc -O2 -o extractor src_c/extractor.c src_c/utils.c
    gcc -O2 -o jpextractor src_c/jpextractor.c src_c/jputils.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp extractor $out/bin/bof3-extractor
    cp jpextractor $out/bin/bof3-jpextractor

    # Install .txt data files (lookup tables)
    mkdir -p $out/share/bof3-text-extractor
    cp *.txt $out/share/bof3-text-extractor/

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/bof3-jpextractor --set BOF3_DATA_DIR $out/share/bof3-text-extractor
  '';

  meta = with lib; {
    description = "Text extractor for Breath of Fire III";
    longDescription = ''
      A tool to extract the dialogue sections from AREAxxx.EMI files found in
      Breath of Fire III's game files. Supports both English and Japanese text
      extraction.
    '';
    homepage = "https://github.com/glitch-in-the-herring/bof3-text-extractor";
    license = licenses.mit;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "bof3-extractor";
  };
}

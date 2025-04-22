{ lib
, stdenv
, fetchFromGitHub
, zydis
, elfutils
, zlib
, xxd
, multimarkdown
, gcc
, binutils
, coreutils
, gnugrep
}:

stdenv.mkDerivation rec {
  pname = "e9patch";
  version = "1.0.0-rc10-unstable-2024-08-07";

  src = fetchFromGitHub {
    owner = "GJDuck";
    repo = "e9patch";
    rev = "bde56202995716542b9ab6661d8f7f19b491d338";
    hash = "sha256-cjgnGNIRRpU1AHH8JkHJI11ii4S/iodD44UulQXK8jg=";
  };

  postPatch = ''
    # fix: install: cannot create directory '/usr': Permission denied
    cp ${./Makefile} Makefile

    echo "patching e9compile.sh"
    substituteInPlace e9compile.sh \
      --replace-warn \
        "#!/bin/sh" \
        "#!/bin/sh"$'\n'"export PATH='${lib.makeBinPath runtimeInputs}':\"$PATH\""

    # fix colors
    sed -i -E s/'="\\033\[([0-9]+)m"'/"=$'\\\\033[\1m'"/ e9compile.sh

    # fix warning. %zu -> %u
    substituteInPlace src/e9tool/e9cfg.cpp \
      --replace-warn \
        'fprintf(stream, "%p,%+zd,%zu\n", (void *)(uintptr_t)Is[i].address,' \
        'fprintf(stream, "%p,%+zd,%u\n", (void *)(uintptr_t)Is[i].address,' \
  '';

  nativeBuildInputs = [
    xxd
    multimarkdown
  ];

  buildInputs = [
    zydis
    elfutils
    zlib
  ];

  # fix: install: cannot create directory '/usr': Permission denied
  makeFlags = [ "prefix=$(out)" ];

  runtimeInputs = [
    gcc
    binutils # objdump readelf
    coreutils # head
    gnugrep
  ];

  meta = with lib; {
    description = "A powerful static binary rewriting tool";
    homepage = "https://github.com/GJDuck/e9patch";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "e9patch";
    platforms = platforms.all;
  };
}

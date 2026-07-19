##########################################################################
#                                                                        #
#  This file is part of the elzorrorebelde/nur project                   #
#                                                                        #
#  Copyright (C) 2026 Jorge Javier Araya Navarro                         #
#                                                                        #
#  SPDX-License-Identifier: MIT                                          #
#                                                                        #
##########################################################################

{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "ppf";
  version = "3.0-unstable-2018-09-01";

  src = fetchFromGitHub {
    owner = "meunierd";
    repo = "ppf";
    rev = "4f24f8c784faf27b54081caee3835fa59a8a009e";
    hash = "sha256-fqrllhAQCH0pm+TiLVEj0qVXuWsIrme1USloTup7Q9k=";
  };

  buildPhase = ''
    runHook preBuild

    gcc \
      -D_LARGEFILE_SOURCE \
      -D_FILE_OFFSET_BITS=64 \
      -D_LARGEFILE64_SOURCE \
      -O2 \
      -o applyppf3 \
      "$src/ppfdev/applyppf_src/applyppf3_linux.c"

    gcc \
      -D_LARGEFILE_SOURCE \
      -D_FILE_OFFSET_BITS=64 \
      -D_LARGEFILE64_SOURCE \
      -O2 \
      -o makeppf3 \
      "$src/ppfdev/makeppf_src/makeppf3_linux.c"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp applyppf3 $out/bin/
    cp makeppf3  $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "PPF3.0 patch creation and application tool";
    longDescription = ''
      PPF (PlayStation Patch File) is a binary patch format widely used in the
      console modding scene, particularly for PlayStation and PlayStation 2
      disc images. This package provides both the creation tool (makeppf3) and
      the application tool (applyppf3) for PPF3.0 patches, as well as
      legacy support for PPF1.0 and PPF2.0 patches in the application tool.
    '';
    homepage = "https://github.com/meunierd/ppf";
    license = lib.licenses.free; # source says "Feel free to use" — no standard OSI license
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "makeppf3";
  };
}

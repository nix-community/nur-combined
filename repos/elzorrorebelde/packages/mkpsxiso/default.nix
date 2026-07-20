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
  cmake,
  fetchgit,
}:

let
  version = "2.30";
in
stdenv.mkDerivation {
  pname = "mkpsxiso";
  inherit version;

  src = fetchgit {
    url = "https://github.com/Lameguy64/mkpsxiso.git";
    rev = "refs/tags/v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-1TcI+0gv65T9+u+1wFtpLt022mPD+oz2vsslgnjfJ6E=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "PlayStation ISO image maker & dumping tool";
    longDescription = ''
      mkpsxiso is a PlayStation ISO image maker and dumping tool. It can build
      PlayStation-compatible ISO images from XML project files and dump/extract
      existing PlayStation ISO images into XML project files.
    '';
    homepage = "https://github.com/Lameguy64/mkpsxiso";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "mkpsxiso";
  };
}

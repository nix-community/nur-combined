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
  lib,
  stdenv,
  fetchgit,
  perl,
  makeWrapper,
}:

let
  version = "0.0.10";
  rev = "6f6ed57990e33459825a729000253c48e9b85ccc";
in
stdenv.mkDerivation {
  pname = "abw-abcde";
  inherit version;

  src = fetchgit {
    url = "https://rosa.radicle.network/z3uEE5Uor7xhqKDNhQt2EkkeUijA5.git";
    inherit rev;
    sha256 = "sha256-loZFtUN78Olvb3D4ENx8CLxEt01raBN/Hzpks+ye4+0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    # Install Perl modules into the Perl library path
    mkdir -p "$out/${perl.libPrefix}"
    cp -r abcde "$out/${perl.libPrefix}/"
    cp -r cpan/Hash "$out/${perl.libPrefix}/"

    # Install the main script
    mkdir -p "$out/share/abw-abcde"
    cp abcde.pl "$out/share/abw-abcde/"

    # Create wrapper script as 'abw-abcde'
    makeWrapper "${perl}/bin/perl" "$out/bin/abw-abcde" \
      --add-flags "$out/share/abw-abcde/abcde.pl" \
      --set PERL5LIB "$out/${perl.libPrefix}"

    # Install documentation
    mkdir -p "$out/share/doc/abw-abcde"
    cp -r docs/* "$out/share/doc/abw-abcde/"
    cp README.md "$out/share/doc/abw-abcde/"

    # Install examples
    mkdir -p "$out/share/abw-abcde/examples"
    cp -r eg/* "$out/share/abw-abcde/examples/"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Script extraction/insertion utility for ROM hacking (replacement for Atlas & Cartographer)";
    longDescription = ''
      abcde is a script extraction/insertion utility that aims to take as many of
      the things that are good about Atlas and Cartographer as possible and make
      them even better.

      It implements all features supported by Cartographer and Atlas, corrects many
      bugs, and adds new features including: expanded table file syntax with support
      for non-octet text encodings (e.g. 6-bit tokens, Huffman encodings),
      mid-string encoding changes (table switching), new extraction and insertion
      commands, and an improved text-to-binary algorithm based on A* search.
    '';
    homepage = "https://www.romhacking.net/utilities/1392/";
    license = licenses.unfreeRedistributable;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "abw-abcde";
  };
}

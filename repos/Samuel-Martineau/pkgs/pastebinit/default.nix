# Copyright (c) 2003-2023 Eelco Dolstra and the Nixpkgs/NixOS contributors

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


{ lib
, stdenv
, fetchFromGitHub
, python3
, libxslt
, docbook_xsl
, installShellFiles
, callPackage
}:
stdenv.mkDerivation
  (rec {
    version = "1.6.2";
    pname = "pastebinit";

    src = fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = version;
      hash = "sha256-vuAWkHlQM6QTWarThpSbY0qrxzej0GvLU0jT2JOS/qc=";
    };

    patches = [
      ./use-drv-etc.patch
    ];

    nativeBuildInputs = [
      libxslt
      installShellFiles
    ];

    buildInputs = [
      (python3.withPackages (p: [ p.distro ]))
    ];

    buildPhase = ''
      xsltproc --nonet ${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl pastebinit.xml
    '';

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/etc
      cp -a pastebinit $out/bin
      cp -a utils/* $out/bin
      cp -a pastebin.d $out/etc
      substituteInPlace $out/bin/pastebinit --subst-var-by "etc" "$out/etc"
      installManPage pastebinit.1
    '';

    passthru.tests.test = callPackage ./test.nix { };

    meta = with lib; {
      homepage = "https://stgraber.org/category/pastebinit/";
      description = "A software that lets you send anything you want directly to a pastebin from the command line";
      maintainers = with maintainers; [ raboof ];
      license = licenses.gpl2;
      platforms = platforms.linux ++ lib.platforms.darwin;
    };
  })

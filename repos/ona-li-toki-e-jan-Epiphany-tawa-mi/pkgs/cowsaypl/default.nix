{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "cowsaypl";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "cowsAyPL";
    #rev   = "RELEASE-V${version}";
    # Bug fix for reading from stdin.
    rev   = "989ed1de3f27333e55d3cf2346206c8f61aebf9e";
    hash  = "sha256-JpLCYpDtYQrAyjdtodH/pZS5r2t9em3YzItBWl6H8m8=";
  };

  buildInputs = [ gnuapl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp cowsay.apl $out/bin/${pname}
    cp workspaces/* $out/lib

    # Rewrite library loads to use paths from the Nix store.
    sed -i -e "s|⊣ ⍎\")COPY_ONCE fio.apl\"|⊣ ⍎\")COPY_ONCE $out/lib/fio.apl\"|"      \
        -e "s|⊣ ⍎\")COPY_ONCE logging.apl\"|⊣ ⍎\")COPY_ONCE $out/lib/logging.apl\"|" \
           $out/bin/${pname}
    sed -i -e "s|⊣ ⍎\")COPY_ONCE fio.apl\"|⊣ ⍎\")COPY_ONCE $out/lib/fio.apl\"|" \
        $out/lib/logging.apl

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cowsay in GnuAPL";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/cowsAyPL";
    license     = licenses.mit;
    mainProgram = pname;
  };
}

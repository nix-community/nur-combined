{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "cowsaypl";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "cowsAyPL";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-KUSFKXIUFh9Qu0lyqfHJI26DDkPeRw5gkXYC56UClYo=";
  };

  buildInputs = [ gnuapl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp cowsay.apl $out/bin/${pname}
    cp workspaces/* $out/lib

    # Rewrite library loads to use paths from the Nix store.
    sed -i -e "s|⊣ ⍎\")COPY_ONCE fio.apl\"|⊣ ⍎\")COPY_ONCE $out/lib/fio.apl\"|" \
           $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cowsay in GnuAPL";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/cowsAyPL";
    license     = licenses.gpl3Plus;
    mainProgram = pname;
  };
}

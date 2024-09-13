{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "ahd";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "AHD";
    rev   = version;
    hash  = "sha256-VesCMC5bD/geTtO/O4nJxVtTXSzYHyCbEJCBalrtIrA=";
  };

  buildInputs = [ gnuapl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp ahd.apl $out/bin/${pname}
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
    description = "Hexdump utility";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/AHD";
    licenses    = with licenses; [ gpl3Plus zlib ];
    mainProgram = pname;
  };
}

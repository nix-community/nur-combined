{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "ahd";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "AHD";
    # Hotfix for crash on reading from stdin.
    rev   = "69fcefc03b0d2a35b30a178a19da593582aa5749";
    hash  = "sha256-u6s6X52EfXCIsAYtHgelJYrDO8ktRL0EWZaj8rpJfbA=";
  };

  buildInputs       = [ gnuapl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp ahd.apl $out/bin/${pname}
    cp workspaces/* $out/lib

    # Rewrite library loads to use paths from the Nix store.
    sed -i "s|⊣ ⍎\")COPY_ONCE fio.apl\"|⊣ ⍎\")COPY_ONCE $out/lib/fio.apl\"|" \
           $out/bin/${pname}
    sed -i "s|⊣ ⍎\")COPY_ONCE logging.apl\"|⊣ ⍎\")COPY_ONCE $out/lib/logging.apl\"|" \
        $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hexdump utility";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/AHD";
    licenses    = with licenses; [ gpl3Plus zlib ];
    mainProgram = pname;
  };
}

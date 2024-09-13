{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "cowsaypl";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "cowsAyPL";
    rev   = "RELEASE-V${version}";
    hash  = "sha256-EBl/LG+WlX8ygxY7j7xJNpf656cVcKtaDLiY3wStvYY=";
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
    licenses    = with licenses; [ mit zlib ];
    mainProgram = pname;
  };
}

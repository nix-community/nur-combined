{ stdenv
, fetchFromGitHub
, lib
, gnuapl
}:

stdenv.mkDerivation rec {
  pname   = "ahd";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = "AHD";
    rev   = version;
    hash  = "sha256-cbbe2OVbv1N71wctSTElKFp41G15446HJGZLGQuSmY8=";
  };

  buildInputs = [ gnuapl ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib"
    cp ahd.apl "$out/bin/${pname}"
    cp workspaces/* "$out/lib"

    # Rewrite library loads to use paths from the Nix store.
    sed -i -e "s|⊣ ⍎\")COPY_ONCE fio.apl\"|⊣ ⍎\")COPY_ONCE $out/lib/fio.apl\"|" \
        $out/bin/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hexdump utility";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/AHD";
    license     = licenses.gpl3Plus;
    mainProgram = pname;
  };
}

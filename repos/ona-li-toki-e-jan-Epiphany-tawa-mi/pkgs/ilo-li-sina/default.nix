{ stdenv
, fetchFromGitHub
, lib
, cmake
, python312
, ncurses
}:

stdenv.mkDerivation rec {
  pname   = "ilo-li-sina";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "ona-li-toki-e-jan-Epiphany-tawa-mi";
    repo  = pname;
    rev   = "a92d17b95b3a767b855c9b4f953cb853a21e5b4e";
    hash  = "sha256-qno00Yqn/XFkBkWBHcKBNI4RVjDgKgiKUM/R1QEK1M4=";
  };

  nativeBuildInputs = [ cmake python312 ncurses ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ilo_li_sina $out/bin/ilo-li-sina

    runHook postInstall
  '';

  meta = with lib; {
    description = "li toki pi lawa pi ilo nanpa. taso, sina lawa ala e ona. ona li lawa e sina a!";
    homepage    = "https://github.com/ona-li-toki-e-jan-Epiphany-tawa-mi/ilo-li-sina";
    license     = licenses.mit;
    mainProgram = "ilo-li-sina";
  };
}

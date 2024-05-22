{ lib
, stdenv
, fetchFromGitHub
, bison
, python3
}:

stdenv.mkDerivation rec {
  pname = "bash2py";
  version = "3.6";

  src = fetchFromGitHub {
    owner = "clarity20";
    repo = "bash2py";
    rev = "aac86d999548f9b569b54c656bd296a6eb4ec8a3";
    hash = "sha256-qsxV6MU/w/6DgoyPzMjpECvJOqYOkh/Wlc3PiA4FYkY=";
  };

  # FIXME segfault
  dontStrip = true; # add "-g" to cflags?

  # va_list args = *pArgs;
  # error: invalid initializer
  # https://github.com/clarity20/bash2py/issues/52

  # fprintf(g_log_stream, log_entry);
  # error: format not a string literal and no format arguments
  # https://github.com/clarity20/bash2py/issues/54

  # bash2pyengine: .made
  #   mv bash bash2pyengine
  #   mkdir -p ~/bin
  #   cp bash2pyengine ~/bin/bash2pyengine

  # "make bash2pyengine" should not install bash2pyengine
  # https://github.com/clarity20/bash2py/issues/55

  postPatch = ''
    substituteInPlace bash-*/burp.c \
      --replace-warn \
        'va_list args = *pArgs;' \
        'va_list args;' \
      --replace-warn \
        'while (TRUE)' \
        'va_copy(args, *pArgs); while (TRUE)' \
      --replace-warn \
        'return result;' \
        'va_end(args); return result;' \
      --replace-warn \
        'fprintf(g_log_stream, log_entry);' \
        'fprintf(g_log_stream, "%s", log_entry);' \

    substituteInPlace bash-*/Makefile.in \
      --replace-warn 'mkdir -p ~/bin' "" \
      --replace-warn 'cp bash2pyengine ~/bin/bash2pyengine' "" \
  '';

  #strictDeps = true;

  #depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = (
    [
      bison # yacc
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin stdenv.cc.bintools
  );

  #buildInputs = lib.optional interactive readline;

  # https://github.com/clarity20/bash2py/raw/master/install
  /*
    #!/bin/sh
    cd bash-4.3.30
    chmod +x configure && ./configure
    make bash2pyengine
    ls -l bash2pyengine
    cd ..
  */

  configurePhase = ''
    cd bash-*
    chmod +x configure
    patchShebangs configure
    ./configure
  '';

  buildPhase = ''
    make bash2pyengine
  '';

  installPhase = ''
    install -D bash2pyengine $out/bin/bash2pyengine
    cd ..
    sed -i -E "s|bash-[^ /]+/bash2pyengine|$out/bin/bash2pyengine|" bash2py.py
    # add shebang line
    sed -i '1 i\#!${python3}/bin/python3' bash2py.py
    chmod +x bash2py.py
    install -D bash2py.py $out/bin/bash2py
  '';

  meta = with lib; {
    description = "Bash to Python transpiler";
    homepage = "https://github.com/clarity20/bash2py";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "bash2py";
    platforms = platforms.all;
  };
}

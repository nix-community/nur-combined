{ stdenv
, fetchFromGitHub
, sources
, runtimeShell
, writeScript
, procps
, binutils-unwrapped
, gdb
, python3
}:
let
  initGef = writeScript "init-gef" ''
    source @out@/share/gef/gef.py
  '';

  gdbGef = writeScript "gdb-gef" (
    with stdenv.lib; ''
      #!${runtimeShell}
      export PATH="${makeBinPath [ procps binutils-unwrapped python3 ]}:$PATH"
      export NIX_PYTHONPATH="${pythonPath}"
      ${gdb}/bin/gdb -x @out@/share/gef/init-gef "$@"
    ''
  );

  pythonPath = with python3.pkgs; makePythonPath [
    capstone
    unicorn
  ];
in
stdenv.mkDerivation {
  pname = "gef-unstable";
  version = stdenv.lib.substring 0 10 sources.gef.date;

  src = sources.gef;

  dontBuild = true;
  doCheck = false;

  installPhase = ''
    install -Dm644 gef.py -t $out/share/gef
    install -Dm644 ${initGef} $out/share/gef/init-gef
    install -Dm755 ${gdbGef} $out/bin/gdb-gef
  '';

  postFixup = ''
    substituteInPlace $out/share/gef/init-gef --subst-var out
    substituteInPlace $out/bin/gdb-gef --subst-var out
  '';

  meta = with stdenv.lib; {
    inherit (sources.gef) description homepage;
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ maintainers.sikmir ];
  };
}

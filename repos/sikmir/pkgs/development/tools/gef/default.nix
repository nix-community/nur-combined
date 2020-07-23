{ stdenv
, fetchFromGitHub
, sources
, runtimeShell
, writeScript
, procps
, binutils-unwrapped
, bash
, python3
, gdb
}:
let
  pname = "gef";
  date = stdenv.lib.substring 0 10 sources.gef.date;
  version = "unstable-" + date;

  initGef = writeScript "init-gef" ''
    source @out@/share/gef/gef.py
  '';

  gdbGef = writeScript "gdb-gef" (
    with stdenv.lib; ''
      #!${runtimeShell}
      export PATH="${makeBinPath [ procps binutils-unwrapped ]}:$PATH"
      ${gdb}/bin/gdb -x @out@/share/gef/init-gef "$@"
    ''
  );
in
stdenv.mkDerivation {
  inherit pname version;
  src = sources.gef;

  postPatch = ''
    substituteInPlace gef.py \
      --replace "/bin/ps" "ps" \
      --replace "/bin/bash" "${bash}/bin/bash" \
      --replace "/usr/bin/python" "${python3.interpreter}"
  '';

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

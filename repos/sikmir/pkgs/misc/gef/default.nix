{ lib
, stdenv
, fetchFromGitHub
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
    with lib; ''
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
stdenv.mkDerivation rec {
  pname = "gef";
  version = "2021.07";

  src = fetchFromGitHub {
    owner = "hugsy";
    repo = pname;
    rev = version;
    hash = "sha256-zKn3yS9h8bzjsb/iPgNU8g5IgXFBaKvM7osTqzzv16s=";
  };

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

  meta = with lib; {
    description = "GDB Enhanced Features for exploit devs & reversers";
    homepage = "http://gef.rtfd.io/";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ maintainers.sikmir ];
  };
}

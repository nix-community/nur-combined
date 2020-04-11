{ stdenv, fetchFromGitHub, sources, runtimeShell, procps, binutils-unwrapped, bash, python3, gdb }:

stdenv.mkDerivation rec {
  pname = "gef";
  version = stdenv.lib.substring 0 7 src.rev;
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
    echo "source $out/share/gef/gef.py" > $out/share/gef/init-gef
    install -dm755 $out/bin
    cat << EOF > $out/bin/gdb-gef
    #!${runtimeShell}
    export PATH="${stdenv.lib.makeBinPath [ procps binutils-unwrapped ]}:\$PATH"
    ${gdb}/bin/gdb -x $out/share/gef/init-gef "\$@"
    EOF
    chmod +x $out/bin/gdb-gef
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ sikmir ];
  };
}

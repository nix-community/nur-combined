{ stdenv, fetchFromGitHub, gawk
, outputsToInstall ? [ "bin" "lib" "man" ]
}:

let noweb = stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  version = "2.12";
  pname = "noweb";
  tlType = "run";

  src = fetchFromGitHub {
    owner = "nrnrnr";
    repo = "noweb";
    rev = "v${builtins.replaceStrings ["."] ["_"] version}";
    sha256 = "1160i2ghgzqvnb44kgwd6s3p4jnk9668rmc15jlcwl7pdf3xqm95";
  };

  outputs = [ "out" "bin" "lib" "man" "tex" ];

  preBuild = ''
    mkdir -p "$lib/lib/noweb"
    cd src
  '';

  installFlags = [
    "BIN=$(bin)/bin"
    "LIB=$(lib)/lib/noweb"
    "MAN=$(man)/share/man"
    "TEXINPUTS=$(tex)/tex/latex/noweb"
  ];

  preInstall = ''
    mkdir -p "$tex/tex/latex/noweb"
  '';

  postInstall= ''
    substituteInPlace "$bin/bin/cpif" --replace "PATH=/bin:/usr/bin" ""

    for f in $bin/bin/no{index,roff,roots,untangle,web} \
             $lib/lib/noweb/to{ascii,html,roff,tex} \
             $lib/lib/noweb/{bt,empty}defn \
             $lib/lib/noweb/{noidx,unmarkup}; do
      substituteInPlace "$f" --replace "nawk" "${gawk}/bin/awk"
    done

      ln -s "$bin/bin" "$out/bin"
      ln -s "$lib/lib" "$out/lib"
  '';

  patches = [ ./no-FAQ.patch ];

  meta = with stdenv.lib; {
    outputsToInstall = [ "bin" "lib" "man" ];
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ yurrriq ];
  };
}; in noweb // { pkgs = [ noweb.tex ]; }

{ stdenv, fetchFromGitHub, gawk, icon-lang, lndir }:

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

  outputs = [ "out" "texmf" ];

  preBuild = ''
    mkdir -p "$out/lib/noweb"
    cd src
    makeFlags="BIN=$out/bin LIB=$out/lib/noweb MAN=$out/share/man TEXINPUTS=$texmf/tex/latex/noweb LIBSRC=icon ICONC=icont"
  '';

  preInstall = ''
    mkdir -p "$texmf/tex/latex/noweb"
    mkdir -p "$out/share/texmf"
  '';

  postInstall= ''
    substituteInPlace "$out/bin/cpif" --replace "PATH=/bin:/usr/bin" ""

    for f in $out/bin/no{index,roff,roots,untangle,web} \
             $out/lib/noweb/to{ascii,html,roff,tex} \
             $out/lib/noweb/{bt,empty}defn \
             $out/lib/noweb/{noidx,unmarkup}; do
      substituteInPlace "$f" --replace "nawk" "${gawk}/bin/awk"
    done

    lndir -silent "$texmf" "$out/share/texmf"
  '';

  patches = [ ./no-FAQ.patch ];

  nativeBuildInputs = [ lndir ];

  buildInputs = [ icon-lang ];

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = with maintainers; [ yurrriq ];
  };
}; in noweb // { pkgs = [ noweb.texmf ]; }

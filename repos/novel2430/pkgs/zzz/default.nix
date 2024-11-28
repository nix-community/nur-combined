{stdenv, fetchFromGitHub, lib
, asciidoctor
, gnumake
}:
stdenv.mkDerivation {
  pname = "zzz";
  version = "0.2.0";
  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "zzz";
    rev = "c068eedab22a58e95fdba5e86b461058113b2eca";
    sha256 = "sha256-gm/fzhgGM2kns051PKY223uesctvMj9LmLc4btUsTt8=";
  };

  buildInputs = [
    asciidoctor
  ];

  nativeBuildInputs = [ gnumake ];

  installPhase = ''
    mkdir -p $out
    make install DESTDIR="$out" prefix=/ sbindir=/bin 
    rm -r $out/etc
  '';

  meta = with lib; {
    description = "A simple program to suspend or hibernate your computer 💤";
    homepage = "https://github.com/jirutka/zzz";
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = with licenses; [ mit ];
  };
}

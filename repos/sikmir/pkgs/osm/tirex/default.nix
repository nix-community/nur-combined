{ lib, stdenv, fetchFromGitHub, makeWrapper, cairo, mapnik, perl, perlPackages }:

stdenv.mkDerivation rec {
  pname = "tirex";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "tirex";
    rev = "v${version}";
    hash = "sha256-0QbPfCPBdNBbUiZ8Ppg2zao98+Ddl3l+yX6y1/J50rg=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace "/usr" "" --replace ": Makefile.perl" ":"
    substituteInPlace backend-mapnik/Makefile --replace "/usr" ""
    substituteInPlace lib/Tirex.pm --replace "/etc" "$out/etc"
  '';

  preConfigure = ''
    perl Makefile.PL PREFIX=$out DESTDIR= FIRST_MAKEFILE=Makefile.perl
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ cairo mapnik perl ];

  installFlags = [ "DESTDIR=$(out)" "INSTALLOPTS:=" ];

  installTargets = [ "install-all" ];

  preInstall = ''
    # https://github.com/openstreetmap/tirex/pull/42
    install -m 755 -d $out/libexec
  '';

  postInstall = ''
    mv $out$out/lib/* $out/lib
    mv $out$out/man/* $out/man
    rm -r $out/nix
  '';

  postFixup = ''
    for cmd in `ls $out/bin`; do
      wrapProgram $out/bin/$cmd \
        --prefix PERL5LIB : "${with perlPackages; makeFullPerlPath [ JSON IpcShareLite ]}:"$out/lib/perl5
    done
  '';

  meta = with lib; {
    description = "Tirex tile queue manager";
    homepage = "http://wiki.openstreetmap.org/wiki/Tirex";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}


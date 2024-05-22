{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  makeWrapper,
  boost,
  cairo,
  harfbuzz,
  icu,
  libtiff,
  libwebp,
  mapnik,
  perl,
  perlPackages,
  proj,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tirex";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "openstreetmap";
    repo = "tirex";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0QbPfCPBdNBbUiZ8Ppg2zao98+Ddl3l+yX6y1/J50rg=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/openstreetmap/tirex/pull/54/commits/da0c5db926bc0939c53dd902a969b689ccf9edde.patch";
      hash = "sha256-bnL1ZGy8ZNSZuCRbZn59qRVLg3TL0GjFYnhRKroeVO0=";
    })
  ];

  postPatch = ''
    substituteInPlace Makefile --replace-fail "/usr" "" --replace-fail ": Makefile.perl" ":"
    substituteInPlace backend-mapnik/Makefile --replace-fail "/usr" ""
    substituteInPlace lib/Tirex.pm --replace-fail "/etc" "$out/etc"
  '';

  preConfigure = ''
    perl Makefile.PL PREFIX=$out DESTDIR= FIRST_MAKEFILE=Makefile.perl
  '';

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    boost
    cairo
    harfbuzz
    icu
    libtiff
    libwebp
    mapnik
    perl
    proj
    sqlite
  ];

  installFlags = [
    "DESTDIR=$(out)"
    "INSTALLOPTS:="
  ];

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
        --prefix PERL5LIB : "${
          with perlPackages;
          makeFullPerlPath [
            JSON
            IpcShareLite
          ]
        }:"$out/lib/perl5
    done
  '';

  meta = with lib; {
    description = "Tirex tile queue manager";
    homepage = "http://wiki.openstreetmap.org/wiki/Tirex";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
})

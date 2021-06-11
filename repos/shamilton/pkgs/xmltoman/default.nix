{ lib
, stdenv
, fetchFromGitHub
, perlPackages
, makeWrapper
}:

stdenv.mkDerivation rec {
  pname = "xmltoman";
  version = "0.6";

  src = fetchFromGitHub {
    owner = "atsb";
    repo = "xmltoman";
    rev = version;
    sha256 = "1f4l34xnjyk86l66fpfsy03mdpvrbl9fragss3cc84c1hwc5sq8j";
  };

  postPatch = ''
    substituteInPlace xmltoman \
      --replace "/usr/bin/perl -w" "${perlPackages.perl}/bin/perl -w"
    substituteInPlace Makefile \
      --replace "prefix=/usr/local" "prefix=$out"
  '';

  nativeBuildInputs = [ makeWrapper ];

  propagatedBuildInputs = with perlPackages; [ XMLParser ];

  buildInputs = [
    perlPackages.perl
  ];

  postInstall = ''
    wrapProgram $out/bin/xmltoman \
      --prefix PERL5LIB : $PERL5LIB
  '';

  meta = with lib; {
    description = "Convert xml to groff (manpage) format";
    license = licenses.gpl2Only;
    homepage = "https://github.com/tryone144/compton";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}

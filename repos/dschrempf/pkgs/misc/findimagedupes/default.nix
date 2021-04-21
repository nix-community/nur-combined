{ lib
, fetchFromGitHub
, git
, graphicsmagick
, makeWrapper
, perlPackages
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "findimagedupes";
  version = "2.19.1";

  src = fetchFromGitHub {
    owner = "jhnc";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "19hchaxzzq7kwrcnm3m2zyigq38kdc9l0jp6pz6cm9hfxna58518";
  };

  meta = with lib; {
    # TODO: findimagedupes.
    broken = true;
    description = "Find visually similar or duplicate images";
    homepage = "https://github.com/jhnc/findimagedupes";
    license = licenses.asl20;
    maintainers = with maintainers; [ dschrempf ];
  };

  nativeBuildInputs = with perlPackages; [ makeWrapper PodMarkdown ];

  propagatedBuildInputs = with perlPackages; [ perl graphicsmagick ];

  preBuild = ''
    sed -i -e "s:DIRECTORY => '/usr/local/lib/findimagedupes':DIRECTORY => '/tmp':" findimagedupes
  '';

  buildPhase = "
    pod2man findimagedupes > findimagedupes.1
  ";

  installPhase = ''
    install -D -m 755 findimagedupes $out/bin/findimagedupes
    wrapProgram $out/bin/findimagedupes --set PERL5LIB ${with perlPackages; makeFullPerlPath [ DBFile FileBaseDir FileMimeInfo InlineC ]}
    install -D -m 644 findimagedupes.1 $out/share/man/man1/findimagedupes.1
  '';
}

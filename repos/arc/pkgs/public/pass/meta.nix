{ stdenv
, fetchFromGitHub
, perl
}:

stdenv.mkDerivation {
  pname = "pass-extension-meta";
  version = "2019-03-11";

  src = fetchFromGitHub {
    owner = "rjekker";
    repo = "pass-extension-meta";
    rev = "d5477e1";
    sha256 = "0f0w0lvmmf53q2a4wblhlr9vsziyx9mm9xi80lkd8kw55lq14bhk";
  };

  dontBuild = true;

  installFlags = [ "PREFIX=$(out)" "BASHCOMPDIR=$(out)/share/bash-completion/completions" ];

  inherit perl;
  prePatch = ''
    substituteInPlace src/meta.bash \
      --replace "perl -l" "$perl/bin/perl -l"
  '';

  meta = with stdenv.lib; {
    description = "A pass extension to retrieve meta-data properties";
    homepage = https://github.com/rjekker/pass-extension-meta;
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}

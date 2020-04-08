{ stdenv , fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "id3";
  version = "0.80";
  src = fetchFromGitHub {
    owner = "squell";
    repo = "id3";
    rev = "${version}";
    sha256 = "1sqzhac9y0haz232mg15dx73wzyipwam69gijwmzjj3nm77ym525";
  };

  installPhase = ''
    make install prefix=$out
  '';

  meta = with stdenv.lib; {
    description = "id3 - a command line mass tagger";
    longDescription = ''
      id3  mass tagger is a tool for listing and manipulating ID3 and Lyrics3
      tags in multiple files. It can generate tag fields  from  the  filename
      and other variables, and/or rename files, using an intuitive syntax.

      id3  currently supports old-style ID3v1 tags, Lyrics3v2, as well as the
      more complex ID3v2 format.  This means its  use   is  limited  to  audio
      files which use these formats, i.e. MPEG-1 Layer III.
    '';
    homepage = https://squell.github.io/id3/;
    license = licenses.bsd2;
    platforms = platforms.all;
  };
}

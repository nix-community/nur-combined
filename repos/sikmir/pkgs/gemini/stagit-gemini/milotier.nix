{
  lib,
  stdenv,
  libgit2,
  fetchgit,
}:

stdenv.mkDerivation {
  pname = "stagit-gemini";
  version = "2022-07-08";

  src = fetchgit {
    url = "https://git.milotier.net/stagit-gemini";
    rev = "eddfa077851ffcdbdf377f7920fb481025f7ba31";
    hash = "sha256-U97Ex0OtR8eXvd6vK3rbrGlK7moEvBnVWUTwPyMUgPI=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  buildInputs = [ libgit2 ];

  meta = {
    description = "A fork of stagit-gopher that generates gemtext";
    homepage = "https://git.milotier.net/git/stagit-gemini/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.sikmir ];
  };
}

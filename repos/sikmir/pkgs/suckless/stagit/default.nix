{ lib, stdenv, fetchgit, libgit2 }:

stdenv.mkDerivation {
  pname = "stagit";
  version = "2020-11-28";

  src = fetchgit {
    url = "git://git.codemadness.org/stagit";
    rev = "e1c0aebde443979a524a944027b81f84f4323ff3";
    sha256 = "0gjjkidhscjlmyksphp38i5n5krplx8anhy41zzjjzvsxmavyx1v";
  };

  buildInputs = [ libgit2 ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Static git page generator";
    homepage = "https://git.codemadness.org/stagit/file/README.html";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
  };
}

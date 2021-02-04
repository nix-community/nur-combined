{ lib, stdenv, fetchgit, libX11, farbfeld, farbfeld-utils }:

stdenv.mkDerivation rec {
  pname = "lel";
  version = "0.2";

  src = fetchgit {
    url = "git://git.codemadness.org/lel";
    rev = version;
    sha256 = "1c9gka3ka8j453z8ry50852hnvv5s0b5xjwg6807bj8d536n0jd7";
  };

  postPatch = ''
    substituteInPlace lel-open \
      --replace "jpg2ff" "${farbfeld}/bin/jpg2ff" \
      --replace "png2ff" "${farbfeld}/bin/png2ff" \
      --replace "gif2ff" "${farbfeld-utils}/bin/gif2ff" \
      --replace "lel" "$out/bin/lel"
  '';

  buildInputs = [ libX11 ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Farbfeld image viewer";
    homepage = "https://git.codemadness.org/lel/file/README.html";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

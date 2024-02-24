{ lib, stdenv, fetchgit, libX11, farbfeld, farbfeld-utils }:

stdenv.mkDerivation (finalAttrs: {
  pname = "lel";
  version = "0.2";

  src = fetchgit {
    url = "git://git.codemadness.org/lel";
    rev = finalAttrs.version;
    hash = "sha256-p0lgzSgNyXUAMo/LXhbQZW8LRUGg+Iz+KEQiNYeaL7E=";
  };

  postPatch = ''
    substituteInPlace lel-open \
      --replace-fail "jpg2ff" "${farbfeld}/bin/jpg2ff" \
      --replace-fail "png2ff" "${farbfeld}/bin/png2ff" \
      --replace-fail "gif2ff" "${farbfeld-utils}/bin/gif2ff" \
      --replace-fail "lel" "$out/bin/lel"
  '';

  buildInputs = [ libX11 ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Farbfeld image viewer";
    homepage = "https://git.codemadness.org/lel/file/README.html";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin; # farbfeld-utils is broken
  };
})

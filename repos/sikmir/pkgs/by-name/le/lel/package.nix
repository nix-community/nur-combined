{
  lib,
  stdenv,
  fetchurl,
  libX11,
  farbfeld,
  farbfeld-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lel";
  version = "0.2";

  src = fetchurl {
    url = "https://codemadness.org/releases/lel/lel-${finalAttrs.version}.tar.gz";
    hash = "sha256-y00PnBpIgQaT8V9VL7wvNPOvugFhLXmt0AqZYQY+7dg=";
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

  meta = {
    description = "Farbfeld image viewer";
    homepage = "https://git.codemadness.org/lel/file/README.html";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
  };
})

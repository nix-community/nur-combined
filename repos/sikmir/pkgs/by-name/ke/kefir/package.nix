{
  lib,
  stdenv,
  fetchFromSourcehut,
  m4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "kefir";
  version = "0.5.1";

  src = fetchFromSourcehut {
    owner = "~jprotopopov";
    repo = "kefir";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UQbMPUGxyKRP0LwrLl+Y3jrNm0go4c6misbZV+VzBZI=";
  };

  nativeBuildInputs = [ m4 ];

  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "C17/C23 compiler";
    homepage = "https://kefir.protopopov.lv/";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})

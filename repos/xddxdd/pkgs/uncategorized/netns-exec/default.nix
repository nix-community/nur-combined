{
  stdenv,
  sources,
  lib,
}:
stdenv.mkDerivation rec {
  inherit (sources.netns-exec) pname version src;

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "-m4755" "-m755"

    # Force use sched func from libc
    substituteInPlace iproute2/configure \
      --replace-fail '$CC -I$INCLUDE -o $TMPDIR/setnstest $TMPDIR/setnstest.c' "true"
  '';

  installFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Run command in Linux network namespace as normal user";
    homepage = "https://github.com/pekman/netns-exec";
    license = lib.licenses.gpl2Only;
    mainProgram = "netns-exec";
  };
}

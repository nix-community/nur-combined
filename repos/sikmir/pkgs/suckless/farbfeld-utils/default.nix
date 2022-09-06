{ lib, stdenv, fetchfossil, libGL, libX11, SDL, ghostscript }:

stdenv.mkDerivation {
  pname = "farbfeld-utils";
  version = "2022-07-12";

  src = fetchfossil {
    url = "http://zzo38computer.org/fossil/farbfeld.ui";
    rev = "76efb47dff46e97052f3215d40c2b7cfa277d048";
    sha256 = "sha256-guxTyZmi6w4jrGp+sdLddAur+PJUV3sUoyXC0lmC1LA=";
  };

  buildInputs = [ libGL libX11 SDL ghostscript ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/bin
    $CC -c lodepng.c
    find . -name '*.c' -exec grep 'gcc' {} + -print0 | \
      awk -F: '{print $2}' | sed 's#~/bin#$out/bin#;s#gcc#$CC#;s#/usr/lib/libgs.so.9#-lgs#' | xargs -0 sh -c

    runHook postBuild
  '';

  dontInstall = true;

  meta = with lib; {
    description = "Collection of utilities for farbfeld picture format";
    homepage = "http://zzo38computer.org/fossil/farbfeld.ui/home";
    license = licenses.publicDomain;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

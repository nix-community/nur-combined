{ lib, stdenv, fetchgit }:

stdenv.mkDerivation {
  pname = "sbase";
  version = "2023-12-29";

  src = fetchgit {
    url = "git://git.suckless.org/sbase";
    rev = "2732217a407c03900145e6f4191936ff6a33945a";
    hash = "sha256-/yYGxu2eGI86mGPUGcW2MqAPiTY1GYRaoL+YTadQZw0=";
  };

  makeFlags = [ "AR:=$(AR)" "CC:=$(CC)" "RANLIB:=$(RANLIB)" ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "suckless unix tools";
    homepage = "https://core.suckless.org/sbase/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
}

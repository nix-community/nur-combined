{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  libxml2,
  libxslt,
  pkg-config,
  flex,
  pcre,
  pcre-cpp,
  icu,
  utf8cpp,
  lttoolbox,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apertium";
  version = "3.9.4";

  src = fetchFromGitHub {
    owner = "apertium";
    repo = "apertium";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/47A1dYHsFUsIUVPek0pN+bZbANDvwK0elShpIvij78=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    autoconf
    automake
    libtool
    libxml2
    libxslt
    flex
    pcre
    pcre-cpp
    icu
    utf8cpp
    lttoolbox
  ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail /usr/include/utf8cpp ${lib.getDev utf8cpp}/include/utf8cpp
    sed -i '/stdc++fs/d' configure.ac
  '';

  meta = {
    description = "Free/open-source machine translation platform";
    homepage = "https://www.apertium.org/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})

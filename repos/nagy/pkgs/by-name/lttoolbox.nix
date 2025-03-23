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
  autoreconfHook,
  icu,
  utf8cpp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lttoolbox";
  version = "3.7.6";

  src = fetchFromGitHub {
    owner = "apertium";
    repo = "lttoolbox";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-T92TEhrWwPYW8e49rc0jfM0C3dmNYtuexhO/l5s+tQ0=";
  };

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail /usr/include/utf8cpp ${lib.getDev utf8cpp}/include/utf8cpp
  '';

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
  ];

  meta = {
    description = "Finite state compiler, processor and helper tools used by apertium";
    homepage = "https://github.com/apertium/lttoolbox";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})

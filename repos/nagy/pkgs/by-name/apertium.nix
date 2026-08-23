{
  lib,
  stdenv,
  fetchFromGitHub,
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
  version = "3.9.12";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "apertium";
    repo = "apertium";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/NdXRr5ic1D3tP3NazXF5R3RkD1H0nuMF2RWxXBDa/I=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    flex # lexer generator, build-time only
    libxml2.bin # xmllint, needed at build time (runtime lib stays in buildInputs)
    libxslt.bin # xsltproc, needed at build time
  ];

  buildInputs = [
    flex # runtime: apertium-gen-{de,re}format invoke it for user formats
    libxml2
    libxslt
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
    maintainers = with lib.maintainers; [ nagy ];
  };
})

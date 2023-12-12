{ lib
, stdenv
, fetchFromGitHub
, asciidoctor
, cmake
, gettext
, ninja
, augeas
, boost
, libxml2
, libzypp
, readline
, rpm
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zypper";
  version = "1.14.67";

  src = fetchFromGitHub {
    owner = "opensuse";
    repo = "zypper";
    rev = finalAttrs.version;
    hash = "sha256-nrfBfhEEW0EMAHTJ5pvNrLJngzfIhc6gK4Tx9ClaCeg=";
  };

  nativeBuildInputs = [
    asciidoctor
    cmake
    gettext
    ninja
  ];

  buildInputs = [
    augeas
    boost
    libxml2
    libzypp
    readline
    rpm
  ];

  cmakeFlags = [
    "-DCMAKE_MODULE_PATH=${libzypp}/share/cmake/Modules"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "zypper";
    description = "World's most powerful command line package manager";
    homepage = "https://github.com/opensuse/zypper";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})

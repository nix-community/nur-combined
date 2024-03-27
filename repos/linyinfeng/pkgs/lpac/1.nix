{
  fetchFromGitHub,
  stdenv,
  cmake,
  pkg-config,
  makeWrapper,
  pcsclite,
  curl,
  lib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lpac";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "estkme-group";
    repo = "lpac";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = false;
    sha256 = "sha256-r5vUsj/6/2HWkd3m8V2ApAMvRQU7eIzIlmv9nnuAMLk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];
  buildInputs = [ pcsclite ];

  postInstall = ''
    wrapProgram "$out/bin/lpac" \
      --set APDU_INTERFACE "$out/lib/lpac/libapduinterface_pcsc.so" \
      --set HTTP_INTERFACE "$out/lib/lpac/libhttpinterface_curl.so" \
      --set LIBCURL "${curl.out}/lib/libcurl.so"
  '';

  meta = with lib; {
    description = "C-based eUICC LPA";
    homepage = "https://github.com/estkme-group/lpac";
    mainProgram = "lpac";
    license = [
      licenses.agpl3Plus
      licenses.lgpl21Plus
      licenses.mit
    ];
    maintainers = with maintainers; [ yinfeng ];
  };
})

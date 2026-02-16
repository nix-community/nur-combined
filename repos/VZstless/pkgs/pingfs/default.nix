{
  lib,
  stdenv,
  fetchFromGitHub,
  fuse,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pingfs";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "atlarator";
    repo = "pingfs";
    rev = finalAttrs.version;
    sha256 = "sha256-G0j2vJ2cnmj9TgZ9WHAq/3a7ZD269rLbNtxgm2WHKMs=";
  };

  buildInputs = [ fuse pkg-config ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 0755 pingfs \
      $out/bin/pingfs
    runHook postInstall
  '';

  meta = {
    description = "Stores your data in ICMP ping packets";
    homepage = "https://code.kryo.se/pingfs";
    license = lib.licenses.isc;
    mainProgram = "pingfs";
  };
})

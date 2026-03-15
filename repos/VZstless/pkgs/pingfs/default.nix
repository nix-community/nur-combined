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

  nativeBuildInputs = [ 
    fuse 
    pkg-config 
  ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
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
    longDescription = ''
    pingfs is a filesystem where the data is stored only in the Internet itself, 
    as ICMP Echo packets (pings) travelling from you to remote servers and back again.

    It is implemented using raw sockets and FUSE, so superuser powers are required.
    Linux is the only intended target OS, portability is not a goal.
    Both IPv4 and IPv6 remote hosts are supported.
    '';
    homepage = "https://code.kryo.se/pingfs";
    license = lib.licenses.isc;
    platforms = lib.platforms.linux;
    mainProgram = "pingfs";
  };
})

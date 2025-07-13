{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  fuse3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mqttfs";
  version = "0-unstable-2022-05-01";

  src = fetchFromGitHub {
    owner = "mburakov";
    repo = "mqttfs";
    rev = "84171d09f4af776092230e5c428b07ca21408309";
    hash = "sha256-FYoO4mszo0uZz36+kc527aYdu3CvwZptcibP0bhbWZk=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ fuse3 ];

  makeFlags = [ "bin=mqttfs" ];

  installPhase = ''
    install -Dm755 mqttfs -t $out/bin
  '';

  meta = {
    description = "Access remote MQTT broker as a FUSE filesystem";
    homepage = "https://github.com/mburakov/mqttfs";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.linux;
    skip.ci = stdenv.isDarwin;
  };
})

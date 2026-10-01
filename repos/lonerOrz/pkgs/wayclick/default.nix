{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wayclick";
  version = "0-unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "lonerOrz";
    repo = "wayclick";
    rev = "340441f4e7e7f9b5ba76e88410f091b2ce1e622f";
    hash = "sha256-1Kdhvm0DjUBFMCTL72OGLd1PijOfcvCY8JjVetLJ7cw=";
  };

  cargoHash = "sha256-QYp5B+amLHIY4Yr/kCKngbv4voeBdiY+8czbcWvmdtQ=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    alsa-lib
  ];

  postInstall = ''

    mkdir -p $out/share/wayclick
    cp -r $src/assets/default $out/share/wayclick/config
  '';

  passthru.updateArgs = [ "--version=branch" ];

  meta = {
    description = "Low-latency key click sound engine using evdev + pygame";
    homepage = "https://github.com/lonerOrz/wayclick";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ lonerOrz ];
    mainProgram = "wayclick";
  };
})

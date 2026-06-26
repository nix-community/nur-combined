{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  makeWrapper,
  alsa-lib,
  libGL,
  libX11,
  libXcursor,
  libXi,
  libXrandr,
  libXext,
  libXfixes,
  libXrender,
  libxcb,
}:

rustPlatform.buildRustPackage rec {
  pname = "doukutsu-rs";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "doukutsu-rs";
    repo = "doukutsu-rs";
    rev = version;
    hash = "sha256-iVW7IvUhz+3wXmRsC75Jlo2g4fvoIlAoGavPMQ78f3Q=";
  };

  cargoHash = "sha256-kDBrHsc3SdRfOXi6/JJnb5QrSIeneTM3UUx4reKW+2w=";

  nativeBuildInputs = [
    pkg-config
    cmake
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    libGL
    libX11
    libXcursor
    libXi
    libXrandr
    libXext
    libXfixes
    libXrender
    libxcb
  ];

  env = {
    CMAKE_POLICY_VERSION_MINIMUM = "3.10";
    NIX_CFLAGS_COMPILE = "-std=gnu11";
  };

  doCheck = true;
  cargoTestFlags = [ "--all-targets" ];

  postInstall = ''
    wrapProgram $out/bin/doukutsu-rs \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}"
  '';

  meta = with lib; {
    description = "A reimplementation of the Cave Story engine in Rust";
    homepage = "https://doukutsu.rs/";
    license = licenses.mit;
    maintainers = [ maintainers.lunik1 ];
    platforms = platforms.linux;
    mainProgram = "doukutsu-rs";
  };
}

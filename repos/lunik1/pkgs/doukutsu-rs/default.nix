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
  version = "0.102.0-beta7";

  src = fetchFromGitHub {
    owner = "doukutsu-rs";
    repo = "doukutsu-rs";
    rev = version;
    hash = "sha256-Gi58pGNs5u+tPIiPbprUxgj16vkOU73v19bG6/eR200=";
  };

  cargoHash = "sha256-++rb+jzeQORYrX1vXFb6RQH30ccVoNQD/znZmZOqn5U=";

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

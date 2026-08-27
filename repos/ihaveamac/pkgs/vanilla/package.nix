# Originally taken from: https://github.com/vanilla-wiiu/vanilla/pull/78/commits/b05ea5de2bffded6abe2ff4994bd3de56db1ff97

{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  git,
  openssl,
  gtk4,
  libx11,
  libtiff,
  networkmanager,
  util-linux,
  libnl,
  SDL2,
  SDL2_ttf,
  SDL2_image,
  ffmpeg,
  libxml2,
  libwebp,
  polkit,
  libGL,
  libdrm,
}:
let
  hostap = fetchFromGitHub {
    owner = "vanilla-wiiu";
    repo = "drc-hostap";
    rev = "257096accc39f9c2750a7718ff5751108d15f668";
    hash = "sha256-M0V8y+dkPSM4TY3D9HYTkFCuKp9FVczQ44wDh9qi3GY=";
    leaveDotGit = true;
    passthru = {
      # to allow nix-update to work
      pname = "drc-hostap";
      version = "2.6-unstable-2026-08-24";
      src = hostap;
    };
  };
in
stdenv.mkDerivation rec {
  pname = "vanilla";
  version = "continuous-unstable-2026-08-27";

  src = fetchFromGitHub {
    owner = "vanilla-wiiu";
    repo = pname;
    rev = "94a9a8cd10d917c6f56452e0c6486b2e6154d8d8";
    hash = "sha256-rIXzFGglXAvktM+EHe84ot50mE3XRgy+d1P/13xPLpg=";
  };

  passthru = { inherit hostap; };

  nativeBuildInputs = [
    cmake
    pkg-config
    git
  ];

  buildInputs = [
    openssl
    libx11
    libtiff
    networkmanager
    libnl
    SDL2
    SDL2_ttf
    SDL2_image
    ffmpeg
    libxml2
    libwebp
    polkit
    libGL
    libdrm
  ];

  patches = [ ./fix-sdl2-include.patch ];

  env.NIX_CFLAGS_COMPILE = "-Wno-format-security";

  postPatch = ''
    substituteInPlace pipe/linux/CMakeLists.txt \
        --replace-fail "https://github.com/vanilla-wiiu/drc-hostap.git" "${hostap}"
    sed -i "s/checkout [0-9a-f]*$/checkout fetchgit/" pipe/linux/CMakeLists.txt
  '';

  postInstall = ''
    mkdir -p $polkit/share/polkit-1/{actions,rules.d}
    cp ${./com.mattkc.vanilla.policy} $polkit/share/polkit-1/actions/com.mattkc.vanilla.policy
    cp ${./com.mattkc.vanilla.rules} $polkit/share/polkit-1/rules.d/com.mattkc.vanilla.rules
    substituteInPlace $polkit/share/polkit-1/actions/com.mattkc.vanilla.policy \
      --replace-fail VANILLA_PIPE_PATH $out/bin/vanilla-pipe
  '';

  outputs = [
    "out"
    "polkit"
  ];

  meta = with lib; {
    description = "A software clone of the Wii U GamePad for Linux";
    homepage = "https://github.com/vanilla-wiiu/vanilla";
    license = licenses.gpl2;
    platforms = platforms.linux;
    mainProgram = "vanilla";
  };
}

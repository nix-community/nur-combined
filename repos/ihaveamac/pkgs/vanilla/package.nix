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
    owner = "rolandoislas";
    repo = "drc-hostap";
    rev = "418e5e206786de2482864a0ec3a59742a33b6623";
    hash = "sha256-kAv/PetD6Ia5NzmYMWWyWQll1P+N2bL/zaV9ATiGVV0=";
    leaveDotGit = true;
  };
in
stdenv.mkDerivation rec {
  pname = "vanilla";
  version = "0-unstable-2026-05-14";

  src = fetchFromGitHub {
    owner = "vanilla-wiiu";
    repo = pname;
    rev = "0b42dee05ad8bd0bd0a635be2a86c79ba1fc24e5";
    hash = "sha256-dThwQNNtP5V7PctSH0i7zgks73F15YHLEEWGg5BWrJI=";
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
        --replace-fail "https://github.com/rolandoislas/drc-hostap.git" "${hostap}" \
        --replace-fail "--branch master" "--branch fetchgit"
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

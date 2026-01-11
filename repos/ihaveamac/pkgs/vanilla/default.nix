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
  xorg,
  libtiff,
  networkmanager,
  libsysprof-capture,
  pcre2,
  util-linux,
  libselinux,
  libsepol,
  libnl,
  SDL2,
  SDL2_ttf,
  SDL2_image,
  ffmpeg,
  libxml2,
  libwebp,
  polkit,
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
  version = "continuous-unstable-2026-01-01";

  src = fetchFromGitHub {
    owner = "vanilla-wiiu";
    repo = pname;
    rev = "8e2f86712aba0e9020430dea9aea0a592375d380";
    hash = "sha256-1UQUii6WDS2K9GISKduk4qaTzwuVowPclWit7yZTm6k=";
  };

  passthru = { inherit hostap; };

  nativeBuildInputs = [
    cmake
    pkg-config
    git
    # probably not needed, as the "git clone" has been replaced with a local clone
    #cacert
  ];

  buildInputs = [
    openssl
    # the gui has been replaced with something else... so is this still needed?
    # if removed, i need xorg.libX11 and libtiff
    gtk4
    networkmanager
    #libsysprof-capture
    #pcre2
    # i should determine if this is still needed
    util-linux
    # don't think these two are used at all? the executables don't appear in the source
    #libselinux
    #libsepol
    libnl
    SDL2
    SDL2_ttf
    SDL2_image
    ffmpeg
    libxml2
    libwebp
    polkit
  ];

  patches = [ ./fix-sdl2-include.patch ];

  env.NIX_CFLAGS_COMPILE = "-Wno-format-security";

  postPatch = ''
    substituteInPlace pipe/linux/CMakeLists.txt \
        --replace-fail "https://github.com/rolandoislas/drc-hostap.git" "${hostap}" \
        --replace-fail "--branch master" "--branch fetchgit"

    substituteInPlace cmake/FindLibNL.cmake \
    --replace-fail /usr/include/libnl3 ${lib.getDev libnl}/include/libnl3
  '';

  postInstall = ''
    mkdir -p $polkit/share/polkit-1/{actions,rules.d}
    cp ${./com.mattkc.vanilla.policy} $polkit/share/polkit-1/actions/com.mattkc.vanilla.policy
    cp ${./com.mattkc.vanilla.rules} $polkit/share/polkit-1/rules.d/com.mattkc.vanilla.rules
    substituteInPlace $polkit/share/polkit-1/actions/com.mattkc.vanilla.policy \
      --replace-fail VANILLA_PIPE_PATH $out/bin/vanilla-pipe
  '';

  outputs = [ "out" "polkit" ];

  meta = with lib; {
    description = "A software clone of the Wii U GamePad for Linux";
    homepage = "https://github.com/vanilla-wiiu/vanilla";
    license = licenses.gpl2;
    platforms = platforms.linux;
    mainProgram = "vanilla";
  };
}

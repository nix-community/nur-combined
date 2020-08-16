{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, pkgconfig
, ninja
, meson
, python3Packages
, glslang
, libglvnd
, libXNVCtrl
, xorg
, vulkan-loader
, vulkan-headers
, mesa
, dbus
}:


stdenv.mkDerivation rec {
  pname = "mangohud${lib.optionalString stdenv.is32bit "_32"}";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "flightlessmango";
    repo = "MangoHud";
    rev = "acf2d88fbcb7a7a47f957a87d20739c67049bd0d";
    sha256 = "0qmprnxrvh8bkn6dnrk22v53am3flpixh046w7ach3pnfck1hpfb";
  };

  mesonFlags = [
    # "-Dmangohud_prefix=${libprefix}-"
    "-Dappend_libdir_mangohud=false"
    # "-Dwith_xnvctrl=disabled"
    "-Duse_system_vulkan=enabled"
    "--libdir=lib${lib.optionalString stdenv.is32bit "32"}"
  ];

  buildInputs = [
    libglvnd
    libXNVCtrl
    glslang
    python3Packages.Mako
    xorg.libX11
    vulkan-loader
    vulkan-headers
    mesa
    dbus
  ];

  nativeBuildInputs = [
    pkgconfig
    meson
    ninja
    python3Packages.python
    python3Packages.Mako
    dbus
  ];

  preConfigure = ''
    mkdir -p "$out/share/vulkan/"
    ln -sf "${vulkan-headers}/share/vulkan/registry/" $out/share/vulkan/
    ln -sf "${vulkan-headers}/include" $out
  '';

  meta = with lib; {
    description = "A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more";
    homepage = "https://github.com/flightlessmango/MangoHud";
    platforms = platforms.linux;
    # license = licenses.mit;
    # maintainers = with maintainers; [ zeratax ];
  };
}
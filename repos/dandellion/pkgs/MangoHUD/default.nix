{ stdenv, lib, fetchFromGitHub
, pkgconfig, ninja, meson
, python3Packages, glslang, libglvnd
, xorg, git, vulkan-loader, vulkan-headers}:

let
  version = "0.3.1";
in

stdenv.mkDerivation {
  pname = "mangohud";
  inherit version;

  src = fetchFromGitHub {
    fetchSubmodules = true;
    owner = "flightlessmango";
    repo = "MangoHud";
    rev = "v${version}";
    sha256 = "0sh5kvx3ww0m30zcqc1zjhcw8sqdzv6ay41fb35m7p07f82n95ys";
  };

  mesonFlags = [
    "-Dappend_libdir_mangohud=false"
  ];

  buildInputs = [
    libglvnd glslang python3Packages.Mako
    xorg.libX11 vulkan-loader vulkan-headers
  ];

  nativeBuildInputs = [
    pkgconfig meson ninja
    python3Packages.python python3Packages.Mako
    git
  ];

  postConfigure = ''
    ln -sf "${vulkan-headers}/share/vulkan/registry" ./modules/Vulkan-Headers/
    ln -sf "${vulkan-headers}/include" ./modules/Vulkan-Headers/
  '';
}


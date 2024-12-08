{ lib,
fetchFromGitHub,
rustPlatform,
pkgs,
vulkan-loader
}: let
  buildInputs = with pkgs; [
  ];
  dependencies = with pkgs; [
    vulkan-headers
    vulkan-loader
  ];
in rustPlatform.buildRustPackage rec {
  pname = "memtest_vulkan";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner  = "GpuZelenograd";
    repo   = pname;
    rev    = "v" + version;
    sha256 = "sha256-8tmQtycK7D5bol9v5VL8VkROZbSCndHo+uBvqqFTZjw=";
  };

  libExecPath = "$out/bin/${pname}";

  nativeBuildInputs = buildInputs;
  buildInputs       = dependencies;

  #LD_LIBRARY_PATH = lib.makeLibraryPath dependencies + [
  #  lib.makeLibraryPath [ vulkan-loader ];
  #];

  cargoHash = "sha256-8x8bS0LcvoxoSBWbGdkKzhxDi/9VNab26eidv8YK9dg=";

  meta = with lib; {
    description = "Vulkan compute tool for testing video memory stability ";
    homepage = "https://github.com/GpuZelenograd/memtest_vulkan";
    license = licenses.zlib;
  };
}


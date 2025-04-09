{
  stdenv,
  pkg-config,
  rustPlatform,
  fetchFromGitHub,
  lib,
}:
rustPlatform.buildRustPackage (self: {
  pname = "lux-cli";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "nvim-neorocks";
    repo = "lux";
    tag = "v${self.version}";
    hash = "sha256-xBxDHr7hZD5kCpxpx4G8FVpsFEbc0cRgf99veWtvPrc=";
  };
  useFetchCargoVendor = true;
  cargoHash = "sha256-AVMbcIlfSQ+LcflOqPpD90Ia+GURMABo4M93Vpp1L24=";
})

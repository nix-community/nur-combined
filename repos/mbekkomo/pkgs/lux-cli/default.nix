{
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  libgit2,
  gnupg,
  libgpg-error,
  gpgme,
  luajit,
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

  nativeBuildInputs = [
    pkg-config
  ];

  doCheck = false;

  buildInputs = [
    openssl
    libgit2
    gnupg
    libgpg-error
    gpgme
    luajit
  ];

  env = {
    LIBGIT2_NO_VENDOR =
      if (builtins.match "^24\\.11.+" lib.version) == null then
        1
      else
        0;
    LIBSSH2_SYS_USE_PKG_CONFIG = 1;
    LUX_SKIP_IMPURE_TESTS = 1;
  };

  meta.mainProgram = "lx";
})

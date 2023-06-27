{ lib, fetchFromGitHub, automake, autoconf, libtool, which, openocd, capstone, jimtcl }:

lib.overrideDerivation openocd (drv: {
  version = "riscv";
  name = "openocd-riscv";
  src = fetchFromGitHub {
    owner = "riscv";
    repo = "riscv-openocd";
    fetchSubmodules = true;
    rev = "31812cd13f35ab28011615cce1aac7298dfe35c7";
    sha256 = "sha256-/Zx2a488Fn2xLjojZNPqPs6swyShOpss/rdU1w6oV9Y=";
  };
  nativeBuildInputs = drv.nativeBuildInputs or [] ++ [ automake autoconf libtool which ];
  buildInputs = drv.buildInputs or [] ++ [ capstone jimtcl ];
  preConfigure = ''
    SKIP_SUBMODULE=1 ./bootstrap
  '';
  HOME = "/build/home";
  preBuild = ''
    mkdir -p $HOME
  '';
  ## libusb patch is already applied in riscv fork
  patches = [ ];
})

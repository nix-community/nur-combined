{ lib, stdenv, fetchFromGitHub, pkg-config, libusb1 }:

stdenv.mkDerivation rec {
  pname = "gd32-dfu-utils";
  version = "0.9";
  src = fetchFromGitHub {
    owner = "riscv-mcu";
    repo = "gd32-dfu-utils";
    rev = "v${version}";
    hash = "sha256-R7cka8qWfKRk2YDTgK1maoVufjCBv3HvKprjJDpf30M=";
  };
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];
}



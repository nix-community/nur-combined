{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "scanbuttond";
  version = "0.2.3";
  src = fetchFromGitHub {
    owner = "jdam6431";
    repo = "scanbuttond";
    sha256 = "0fya5mhv1aqhg3kpkfz4cqi46gh5k03ikb8zc6akzdr5aicdd5yi";
    rev = "8a34fdccbe9733123f539291d762537d6681e4d6";
  };
  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ libusb ];

  meta = {
    description = "Daemon to respond to scanner button presses";
    license = stdenv.lib.licenses.gpl2;
    broken = true;
  };
}

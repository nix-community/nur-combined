{ stdenv, rustPlatform, fetchFromGitHub }:
with stdenv.lib;

let
  pname = "agate";
  version = "1.2.2";
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "mbrubeck";
    repo = pname;
    rev = "v${version}";
    sha256 = "0kfr0xysxh830kxwfwmm9gzpl57b3dbkzrj21dnymwr117vjgjrx";
  };

  cargoSha256 = "1ggwc1q998mp6pggxrmhhvnkyrdh6jv1w9jw0x0y2mbn26k54j0p";

  meta = {
    description = "Very simple server for the Gemini hypertext protocol";
    homepage = "https://github.com/mbrubeck/agate";
    license = "MIT/Apache-2.0";
    platforms = platforms.linux;
  };
}

{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "nn";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "meain";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "sha256-qQEu01YXLoGzhqBQmUu/W7jo/aJMZMgpxuUHI9svd58=";
  };

  vendorHash = "sha256-Ev0PaHFy6oNyZ6w4/4FiOEFV3hx/wIuwVmqoauiG/xI=";

  meta = with lib; {
    description = " Quick little bot to run shell commands on servers via matrix";
    license = lib.licenses.asl20;
    homepage = "https://github.com/meain/${pname}";
    platforms = platforms.linux ++ platforms.darwin;
  };
}

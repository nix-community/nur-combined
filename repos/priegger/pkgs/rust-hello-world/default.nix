{ lib, rustPlatform, fetchFromSourcehut }:

rustPlatform.buildRustPackage {
  name = "rust-hello-world";
  preferLocalBuild = true;

  src = fetchFromSourcehut {
    owner = "~priegger";
    repo = "rust-hello-world";
    rev = "2cc1c9483a3139396b8f5afa2c17add415c64ee2";
    hash = "sha256:0flycxaax26phzys67lppsclfcpwjqg02alyp1xm7ql92342v4cf";
  };

  cargoHash = "sha256:01sl7hmv6lzz3hr8gp4njnxnr9wx6byrd1xybwmv50vs2d1sc412";

  meta = with lib; {
    description = "A rust hello world service with rocket and prometheus metrics";
    homepage = "https://git.sr.ht/~priegger/rust-hello-world";
    license = licenses.mit;
    maintainers = [ maintainers.priegger ];
  };
}

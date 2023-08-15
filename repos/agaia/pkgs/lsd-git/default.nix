{ lib, fetchgit, testers, rustPlatform, installShellFiles, pandoc, lsd }:

# Modified from the offical nixpkg https://github.com/NixOS/nixpkgs/blob/9c85697da8e59561151aa279df44ae51a367ed7d/pkgs/tools/misc/lsd/default.nix
rustPlatform.buildRustPackage rec {
  pname = "lsd";
  version = "master";

  src = fetchgit {
    url = "https://github.com/lsd-rs/lsd.git";
    rev = version;
    hash = "";
  };

  cargoSha256 = "sha256-t7J7hIbLlRq99Yd2/3Zn+PbHhJtaJRdDluDXN0Hp/Jc=";

  nativeBuildInputs = [ installShellFiles pandoc ];
  postInstall = ''
    pandoc --standalone --to man doc/lsd.md -o lsd.1
    installManPage lsd.1

    installShellCompletion $releaseDir/build/lsd-*/out/{_lsd,lsd.{bash,fish}}
  '';

  # Found argument '--test-threads' which wasn't expected, or isn't valid in this context
  doCheck = false;

  passthru.tests.version = testers.testVersion {
    package = lsd;
  };

  meta = with lib; {
    homepage = "https://github.com/Peltoche/lsd";
    description = "The next gen ls command";
    license = licenses.asl20;
    maintainers = with maintainers; [ Br1ght0ne marsam zowoq SuperSandro2000 ];
  };
}

# copy this file to directory with your configuration.nix and add this to configuration.nix
# environment.systemPackages = [
#   (pkgs.callPackage ./nix-simple-deploy.nix { })
# ];
{ stdenv, fetchFromGitHub, rustPlatform, lib }:
rustPlatform.buildRustPackage rec {
  pname = "nix-simple-deploy";
  src = fetchFromGitHub {
    owner = "misuzu";
    repo = pname;
    rev = "3d7058f465c71af23e3fffe9cd127d5aa63c2c48";
    sha256 = "1xy1m4xsrrzlk4cfxl5ic2pf78sdc1i5awf1hp04zxhykmznpp6w";
  };
  version = "0.1.1";
  cargoSha256 = "02v8lrwjai45bkm69cd98s5wlvq8w5yz4wfzf7bjcv6n61k05n6f";
  verifyCargoDeps = true;
  meta = with lib; {
    description = "Deploy software or an entire NixOS system configuration to another NixOS system";
    homepage = "https://github.com/misuzu/nix-simple-deploy";
    license = with licenses; [ mit ];
    platforms = platforms.all;
    maintainers = with maintainers; [ misuzu ];
  };
}

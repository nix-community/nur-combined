{ sources, pkgs, buildGoModule, fetchFromGitHub, ... }:
buildGoModule rec {
  pname = "yubikey-touch-detector";
  version = "1.9.0";
  src = fetchFromGitHub {
    inherit (sources.yubikey-touch-detector) owner repo rev sha256;
  };
  vendorSha256 = "07adkp941qvph7x3q7cy8dnvigakc986m92v1vs0imxjcfh7cwij";
  subPackages = [ "." ];
  runVend = true;

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ libnotify ];

  meta = with pkgs.lib; {
    description = "Detect when your YubiKey is waiting for a touch";
    license = licenses.mit;
    homepage = "https://github.com/maximbaz/yubikey-touch-detector";
  };
}

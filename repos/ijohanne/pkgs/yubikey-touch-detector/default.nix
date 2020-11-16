{ sources, pkgs, stdenv, buildGoModule, fetchFromGitHub, ... }:
buildGoModule rec {
  pname = "yubikey-touch-detector";
  version = "1.9.0";
  src = fetchFromGitHub {
    inherit (sources.yubikey-touch-detector) owner repo rev sha256;
  };
  vendorSha256 = "017x3bj93555f3w327zmiyvy0sbpjgz9n9vb8r1zvxlnds7zz627";
  subPackages = [ "." ];
  runVend = true;

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ libnotify ];

  meta = with stdenv.lib; {
    description = "Detect when your YubiKey is waiting for a touch";
    license = licenses.mit;
    homepage = "https://github.com/maximbaz/yubikey-touch-detector";
  };
}

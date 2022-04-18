{ buildGoModule, fetchFromGitHub, lib, fetchgit, darwin, pinentry_mac, ... }:

buildGoModule rec {
  pname = "pinentry-touchid";
  version = "v0.0.3-rc1";
  vendorSha256 = "sha256-FN4F6ZWgSczmAMlEuigLGHivsXjvDJQVBZe6IrJTLrI=";

  src = fetchgit {
    url = "https://github.com/jorgelbg/pinentry-touchid";
    rev = "3ebb30fcabe3916fe0dc776ac0b555d8983545f3";
    sha256 = "sha256-vQJq9Dh2icAJ9R7y/VA1GZcwRpFgOTzKTFz3Vvt713w=";
  };

  subPackages = [ "." ];

  buildInputs = with darwin.apple_sdk.frameworks; [
    CoreFoundation
    Foundation
    LocalAuthentication
  ];
  nativeBuildInputs = [ pinentry_mac ];

  # The above buildInputs causes a problem on aarch64-darwin
  # See https://github.com/NixOS/nixpkgs/issues/160876#issuecomment-1060113970
  NIX_CFLAGS_COMPILE = [
    # disable modules, otherwise we get redeclaration errors
    "-fno-modules"
  ];

  # It does some IO with KeyChain at build time
  doCheck = false;

  ldflags = [ "-s" "-w" "-X main.version=${version}" "-X main.commit=${src.rev}" ];

  doInstallCheck = true;

  meta = with lib; {
    description = "Custom GPG pinentry program for macOS that allows using Touch ID for fetching the password from the macOS keychain.";
    homepage = "https://github.com/jorgelbg/pinentry-touchid";
    licenses = licenses.asl20;
    maintainers = with maintainers; [ congee ];
    mainProgram = "pinentry-touchid";
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    # Well, not really. The GitHub CI just does not evaluate darwin only packages.
    broken = true;
  };
}

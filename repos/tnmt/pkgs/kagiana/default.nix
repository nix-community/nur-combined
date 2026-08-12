{ lib, buildGoModule, fetchFromGitHub, nix-update-script }:

buildGoModule rec {
  pname = "kagiana";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "pyama86";
    repo = "kagiana";
    rev = "v${version}";
    hash = "sha256-88LeAnPkDSI+Cm634L3DQKvDI+P2aaQL/zGZersmZ8k=";
  };

  vendorHash = "sha256-Mctv6NDKpyG/nCMBHZ9gm9DTsz2LW2iBZ67ypLdlS3o=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OAuth Authenticator & Vault Certificate Getter";
    homepage = "https://github.com/pyama86/kagiana";
    license = lib.licenses.mit;
    mainProgram = "kagiana";
  };
}

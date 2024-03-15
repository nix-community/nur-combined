{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "rcon-cli";
  version = "0.10.3";
  src = fetchFromGitHub {
    owner = "gorcon";
    repo = "rcon-cli";
    rev = "v${version}";
    sha256 = "sha256-S2iby8RjIQF9pr1iNLTqAaXGROYTHOI+WjaLGCJdGwA=";
  };

  vendorHash = "sha256-K3GITcOu1FlnwEdrRhgdDV2TUZWy8ig+zy5o0/S97vA=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  passthru = {
    updateScriptEnabled = true;
    updateScript = nix-update-script { attrPath = pname; };
  };

  meta = with lib; {
    description = "RCON client for executing queries on game server";
    homepage = "https://github.com/gorcon/rcon-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ yinfeng ];
  };
}

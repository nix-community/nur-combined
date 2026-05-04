{ lib, buildGoModule, fetchFromGitHub, nix-update-script, go_1_26 }:

(buildGoModule.override { go = go_1_26; }) rec {
  pname = "gogcli";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "gogcli";
    rev = "v${version}";
    hash = "sha256-aau1w6b4nBdTMUTeX0LwV+8YPP5YeghE0iWSaHQXBFQ=";
  };

  vendorHash = "sha256-UTkuqDXo6TnmZBuk18yhqBTT0+u/CebR4/uZw8XOX2k=";

  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/steipete/gogcli/internal/cmd.version=v${version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Google CLI for Gmail, Calendar, Drive, and Contacts";
    homepage = "https://github.com/steipete/gogcli";
    license = lib.licenses.mit;
    mainProgram = "gog";
  };
}

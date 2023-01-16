{ lib
, buildGoModule
, fetchFromGitHub
, pkg-config
, libayatana-appindicator-gtk3
, gtk3 }:

buildGoModule rec {
  pname = "tailscale-systray";
  version = "2022-11-28";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = "tailscale-systray";
    rev = "e7f8893684e7b8779f34045ca90e5abe6df6056d";
    sha256 = "sha256-3kozp6jq0xGllxoK2lGCNUahy/FvXyq11vNSxfDehKE=";
  };

  vendorSha256 = "sha256-cztIq7Kkj5alAYDtbPU/6h5S+nG+KAyxJzHBb3pJujs=";

  buildInputs = [ gtk3 libayatana-appindicator-gtk3 ];
  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    description = "Linux port of tailscale system tray menu";
    homepage = "https://github.com/mattn/tailscale-systray/";
    license = licenses.mit;
    maintainers = with maintainers; [ tboerger ];
  };
}

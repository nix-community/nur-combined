{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "qbittorrent-dual-boot";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Ovenoboyo";
    repo = "qbittorrent_dual_boot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zYeKO+QZraYe5d1B1oSdVMMlNywpUBY0g4EWQ8sYGZo=";
  };

  vendorHash = "sha256-Dg5l6gLD7adq3Brjd7JgqTEvxntMZuEhLR1jqNWeK4o=";

  ldflags = [ "-s" ];

  postInstall = ''
    mv $out/bin/qbitorrent_convert $out/bin/qbittorrent-dual-boot
  '';

  meta = {
    description = "Sync qBittorrent data between Linux and Windows dual boot";
    homepage = "https://github.com/Ovenoboyo/qbittorrent_dual_boot";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ hhr2020 ];
    mainProgram = "qbittorrent-dual-boot";
  };
})

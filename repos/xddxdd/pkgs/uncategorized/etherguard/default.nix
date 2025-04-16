{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule rec {
  pname = "etherguard";
  inherit (sources.etherguard) version src;
  vendorHash = "sha256-9+zpQ/AhprMMfC4Om64GfQLgms6eluTOB6DdnSTNOlk=";

  meta = {
    changelog = "https://github.com/KusakabeShi/EtherGuard-VPN/releases/tag/v${version}";
    mainProgram = "EtherGuard-VPN";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Layer 2 version of WireGuard with Floyd Warshall implementation in Go";
    homepage = "https://github.com/KusakabeShi/EtherGuard-VPN";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}

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
    mainProgram = "EtherGuard-VPN";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Layer2 version of wireguard with Floyd Warshall implement in go";
    homepage = "https://github.com/KusakabeShi/EtherGuard-VPN";
    license = lib.licenses.mit;
  };
}

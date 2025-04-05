{
  buildGoModule,
  lib,
  sources,
}:
buildGoModule rec {
  inherit (sources.usque) pname version src;
  vendorHash = "sha256-njkwrzw/8m4Y1l8aGxaK+JrYbKo/7pCT/ck0bbdaNbU=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    mainProgram = "usque";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Open-source reimplementation of the Cloudflare WARP client's MASQUE protocol";
    homepage = "https://github.com/Diniboy1123/usque";
    license = lib.licenses.mit;
  };
}

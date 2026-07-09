{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "8f14e98f4411f1537ce040124b2ffd7eb5fffa8f";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-Z+TAhtn4BOUk7OY0itom4OpPaUGLHxg0bR6xG6BQY9w=";
  };
  vendorHash = "sha256-oSOZTYS2k4dTCRlipAb/Cxc8dHFgVGh57qHJwdGbjXA=";
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/metacubex/mihomo/constant.Version=${version}"
  ];

  tags = [
    "with_gvisor"
  ];

  # network required
  doCheck = false;

  postInstall = ''
    mv $out/bin/mihomo $out/bin/mihomo-smart
  '';

  meta = with lib; {
    description = "A rule-based tunnel in Go with Smart Groups functionality (fork of mihomo)";
    homepage = "https://github.com/vernesong/mihomo";
    license = licenses.gpl3Only;
    mainProgram = pname;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}

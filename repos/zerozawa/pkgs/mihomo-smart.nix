{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "baef5ee5ac6b4ab84349f9a5251df0fb264c999a";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-6NvWzgevchw4RdLvk59Ndyg49fBwqF6rfEsm3KqDVEg=";
  };
  vendorHash = "sha256-njcAhz2DY5pwfL4NyxwXyLyhZ9SGSXuk18ojrZg0SSA=";
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
    description = "Another Mihomo Kernel.";
    homepage = "https://github.com/vernesong/mihomo";
    license = licenses.gpl3Only;
    mainProgram = pname;
    platforms = platforms.all;
    sourceProvenance = with sourceTypes; [ fromSource ];
  };
}

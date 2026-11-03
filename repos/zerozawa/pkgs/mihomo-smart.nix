{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "77af4804d091d89b871c99b52d50915f4a600d81";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-Q5GQ08/hig8SNxxhDnmNAZSUjTG9/d1kAgSxYUcOf8c=";
  };
  vendorHash = "sha256-XTL/gKKOfsAnMkOU/Uc5Zk3Txvt8uZZlv1S7fPZpF+c=";
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

{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "1933f2962b783cc3689b5484f5333b74cd654f22";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-zYpaXOFhcjGivMftn/JvOktB7oFOEL/mKhvva6GGIjg=";
  };

  vendorHash = "sha256-V3M/hP3+8s12YKS37s1Af4Qa2at/Fp9ARDN0cQYz6WI=";

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

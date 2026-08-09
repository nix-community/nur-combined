{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "d8fc6a6b961328db15bc2b5c4cdf93434fed2ef4";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-Znrq+IjGLHbCxIv05taeNs6eqD92TA9Dx9f81Gk7a0Q=";
  };
  vendorHash = "sha256-j6CFzCx2ucQbH5WG46w8YY+j8IohKeYTWfS4M6/Si8s=";
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

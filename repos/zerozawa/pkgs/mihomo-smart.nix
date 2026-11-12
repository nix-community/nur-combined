{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  rev = "2e6fc107c403ca607714f1613a758e66f12d16e9";
in
buildGoModule rec {
  pname = "mihomo-smart";
  version = "0-unstable-${builtins.substring 0 7 rev}";

  src = fetchFromGitHub {
    owner = "vernesong";
    repo = "mihomo";
    inherit rev;
    hash = "sha256-nTrZ6hPCDSDhOYCv7HX9AGDtbxpPqA1ULZZtA+ttYCE=";
  };
  vendorHash = "sha256-DQPwZEZP4nkgchafiPMdP4nd7oFR6U3O5tJTO8Lei4g=";
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

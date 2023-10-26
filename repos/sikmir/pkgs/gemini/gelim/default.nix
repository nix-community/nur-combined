{ lib, stdenv, buildGoModule, fetchFromSourcehut, scdoc, installShellFiles }:

buildGoModule rec {
  pname = "gelim";
  version = "0.9.3";

  src = fetchFromSourcehut {
    owner = "~hedy";
    repo = "gelim";
    rev = "v${version}";
    hash = "sha256-xFOiE0OLaJ4WK+I8oNXNk7feP3nXp9wvH0bkNnBK1Yg=";
  };

  nativeBuildInputs = [ scdoc installShellFiles ];

  vendorHash = "sha256-sWNPNZYcm296zhz57/NCaAlQxJ+Z1zzd/Y+KiLxZ46E=";

  ldflags = [ "-X main.Version=${version}" ];

  postBuild = ''
    scdoc < gelim.1.scd > gelim.1
  '';

  postInstall = ''
    installManPage gelim.1
  '';

  meta = with lib; {
    description = "A minimalist line-mode smolnet client written in go";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}

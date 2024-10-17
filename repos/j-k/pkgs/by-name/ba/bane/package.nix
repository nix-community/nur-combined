{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "bane";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "genuinetools";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-DvLK42JQlzGOaGpZoFl74nIXZl7U7g80lNTWs4LY438=";
  };

  vendorHash = null;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/genuinetools/bane/version.VERSION=v${version}"
  ];

  doInstallCheck = false;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/bane --help || true
    $out/bin/bane version | grep "v${version}"
    runHook postInstallCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/genuinetools/bane";
    description = "Custom & better AppArmor profile generator for Docker containers";
    longDescription = ''
      AppArmor profile generator for docker containers. Basically a better AppArmor profile, than creating one by hand,
      because who would ever do that.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [ jk ];
  };
}

{
  buildGoModule,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:

buildGoModule rec {
  pname = "easylpac";
  version = "0.7.8.4";

  src = fetchFromGitHub {
    owner = "creamlike1024";
    repo = "EasyLPAC";
    rev = version;
    sha256 = "sha256-vNXeDm2LH5b/upZR1KX326+PMeXzT0fE1VNmPPNpSZU=";
  };
  proxyVendor = true;
  vendorHash = "sha256-tX7abWGn1f4p+7vx2gDa5/NKg5SbWqMfHT8kbPwHK14=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "TODO: fill me";
    longDescription = ''
      TODO: fill me
    '';
    homepage = "https://github.com/creamlike1024/EasyLPAC";
    mainProgram = "TODO";
    # license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ colinsane ];
  };
}

{
  fetchFromGitHub,
  lib,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "konnect";
  version = "0.34.0";
  src = fetchFromGitHub {
    owner = "Kopano-dev";
    repo = "konnect";
    tag = "v0.34.0";
    hash = "sha256-y7SD+czD/jK/m0LbFq7qGjwJgBIXfTNrdsA3pzgD2xE=";
  };
  vendorHash = "sha256-ZrwFUZDTbJx5qvloVOa5qK1ykKNkUn1hjfz0xf+8sWk=";

  passthru.updateScript = nix-update-script { };
  meta = {
    mainProgram = "konnectd";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Kopano Konnect implements an OpenID provider (OP) with integrated web login and consent forms";
    homepage = "https://github.com/Kopano-dev/konnect";
    license = lib.licenses.asl20;
  };
})

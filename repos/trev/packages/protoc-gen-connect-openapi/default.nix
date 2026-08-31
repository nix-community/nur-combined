{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "protoc-gen-connect-openapi";
  version = "0.25.8";

  src = fetchFromGitHub {
    owner = "sudorandom";
    repo = "protoc-gen-connect-openapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l3HwSupBIq+opS0zPxQ2MTZtUgMylnSsCnDEkCKUWgc=";
  };

  vendorHash = "sha256-IoZzOPDMNAM6ugxI5QNknt/rayyYTjoUNBNK9/t9s9M=";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Protobuf plugin for generating OpenAPI specs matching the Connect RPC interface";
    mainProgram = "protoc-gen-connect-openapi";
    homepage = "https://github.com/sudorandom/protoc-gen-connect-openapi";
    changelog = "https://github.com/sudorandom/protoc-gen-connect-openapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})

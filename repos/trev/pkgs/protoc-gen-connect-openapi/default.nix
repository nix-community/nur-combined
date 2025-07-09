{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "protoc-gen-connect-openapi";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "sudorandom";
    repo = "protoc-gen-connect-openapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YMLPzrmp6xtWJY+iSyl9bTLn08auOlfEM7hs7V0Du7M=";
  };

  vendorHash = "sha256-auKQToKsNoCXrBxRK4jaozZTqC8cIsj1TSibvAhH64Q=";

  meta = {
    description = "Plugin for generating OpenAPIv3 from protobufs matching the Connect RPC interface";
    mainProgram = "protoc-gen-connect-openapi";
    homepage = "https://github.com/sudorandom/protoc-gen-connect-openapi";
    changelog = "https://github.com/sudorandom/protoc-gen-connect-openapi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})

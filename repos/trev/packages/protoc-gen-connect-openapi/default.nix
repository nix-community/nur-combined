{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenvNoCC,
  buf,
  cacert,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "protoc-gen-connect-openapi";
  version = "0.30.0";

  src = fetchFromGitHub {
    owner = "sudorandom";
    repo = "protoc-gen-connect-openapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mBWG8KWaiV6ZleRktUTVuvS/+cOv6txsY+6oGDe1dHY=";
  };

  # vacuum is upstream's linter, and its html-report embeds built files that
  # its module doesn't ship, so vendoring it fails
  postPatch = ''
    go mod edit -droptool github.com/daveshanley/vacuum
  '';

  vendorHash = "sha256-2PmJjvdCAJm3WrzI/VpjuykU93YW0sorxoK1uWxnVrs=";

  preCheck = ''
    cp ${finalAttrs.passthru.testdata} internal/converter/testdata/fileset.binpb
  '';

  # the converter's tests run against an image of their protos, which import
  # modules from the Buf Schema Registry
  passthru.testdata = stdenvNoCC.mkDerivation {
    name = "${finalAttrs.pname}-${finalAttrs.version}-testdata";
    inherit (finalAttrs) src;

    nativeBuildInputs = [
      buf
      cacert
    ];

    buildPhase = ''
      runHook preBuild

      cd internal/converter/testdata
      HOME="$TMPDIR" buf build --output "$out"

      runHook postBuild
    '';

    dontInstall = true;
    dontFixup = true;

    outputHashMode = "flat";
    outputHash = "sha256-FA3fCFoUrZ+1Omw6ZdyHeszYdE3Vkrf+38YOhZgb9RE=";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--custom-dep=testdata"
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

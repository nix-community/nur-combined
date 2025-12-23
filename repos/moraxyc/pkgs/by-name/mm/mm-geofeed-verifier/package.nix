{
  lib,
  buildGoModule,
  versionCheckHook,
  sources,
}:

buildGoModule (finalAttrs: {
  pname = "mm-geofeed-verifier";
  inherit (sources.mm-geofeed-verifier) src version;

  vendorHash = "sha256-FVEsxE7B5FA1X+hWq7bloaQs69qFOUkeYv5p22SKkh0=";

  ldflags = [
    "-X=main.version=${finalAttrs.version}"
  ];

  doInstallCheck = true;
  nativeCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-V";

  meta = {
    description = "Verify the format of a geofeed file, and make some comparisons to data in an MMDB file";
    homepage = "https://github.com/maxmind/mm-geofeed-verifier";
    changelog = "https://github.com/maxmind/mm-geofeed-verifier/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "mm-geofeed-verifier";
  };
})

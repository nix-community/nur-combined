{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "hugomods-decap-cms";
  version = "0.16.7";

  src = fetchFromGitHub {
    owner = "hugomods";
    repo = "decap-cms";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XptlzVSLBfY+K6pEublPUvd8J93jS4GbmrIrEgU2AAk=";
  };

  vendorHash = null;

  ldflags = [ "-s" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/hugomods/decap-cms
    cp -r . $out/share/hugomods/decap-cms

    runHook postInstall
  '';


  meta = {
    description = "Experimental] Hugo Decap CMS Module";
    homepage = "https://hugomods.com/docs/decap-cms/";
    changelog = "https://github.com/hugomods/decap-cms/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
  };
})

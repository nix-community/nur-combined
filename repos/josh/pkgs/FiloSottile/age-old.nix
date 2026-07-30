{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "age";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "FiloSottile";
    repo = "age";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9ZJdrmqBj43zSvStt0r25wjSfnvitdx3GYtM3urHcaA=";
  };

  vendorHash = "sha256-ilRLEV7qOBZbqzg2XQi4kt0JAb/1ftT4JmahYT0zSRU=";

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  preInstall = ''
    installManPage doc/*.1
  '';

  doCheck = false;

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${finalAttrs.version}";
    };
  };

  meta = {
    description = "Modern encryption tool with small explicit keys";
    homepage = "https://age-encryption.org/";
    changelog = "https://github.com/FiloSottile/age/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    mainProgram = "age";
  };
})

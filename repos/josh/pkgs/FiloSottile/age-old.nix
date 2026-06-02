{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
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

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  preInstall = ''
    installManPage doc/*.1
  '';

  doCheck = false;

  meta = {
    changelog = "https://github.com/FiloSottile/age/releases/tag/v${finalAttrs.version}";
    homepage = "https://age-encryption.org/";
    description = "Modern encryption tool with small explicit keys";
    license = lib.licenses.bsd3;
    mainProgram = "age";
  };
})

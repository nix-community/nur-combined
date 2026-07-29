{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "age";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "FiloSottile";
    repo = "age";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qs/q3zQYV0PukABBPf/aU5V1oOhw95NG6K301VYJk8A=";
  };

  vendorHash = "sha256-iVDkYXXR2pXlUVywPgVRNMORxOOEhAmzpSM0xqSQMSQ=";

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

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
      version = "v${finalAttrs.version}";
    };

    roundtrip =
      runCommand "test-age-roundtrip"
        {
          __structuredAttrs = true;
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          echo hello nix >message.txt
          age-keygen -o key.txt
          age --encrypt --identity key.txt --output message.txt.age message.txt
          age --decrypt --identity key.txt --output decrypted.txt message.txt.age
          cmp message.txt decrypted.txt
          touch $out
        '';
  };

  meta = {
    changelog = "https://github.com/FiloSottile/age/releases/tag/v${finalAttrs.version}";
    homepage = "https://age-encryption.org/";
    description = "Modern encryption tool with small explicit keys";
    license = lib.licenses.bsd3;
    mainProgram = "age";
  };
})

{
  lib,
  buildGoModule,
  fetchFromGitHub,

  age,
  jq,
  opentofu,

  nix-update-script,
  runCommand,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "tofu-age-encryption";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tofu-age-encryption";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hVogXFXq+hYlaLwK6MF+nm1q6Q1nwXprk8ODsOr/szE=";
  };

  vendorHash = "sha256-xyOevBC3tEi3i/l3rVMG1yUTi0VbUngor6+LbbGZ8p0=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X main.AgePluginPath=${lib.strings.makeBinPath finalAttrs.agePlugins}"
  ];

  agePlugins = [ age ];

  nativeCheckInputs = [
    age
    jq
    opentofu
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  passthru.tests =
    let
      tofu-age-encryption = finalAttrs.finalPackage;
    in
    {
      version = testers.testVersion {
        package = tofu-age-encryption;
        inherit (finalAttrs) version;
      };

      age-path = runCommand "test-tofu-age-encryption-age-path" { } ''
        grep --text --quiet "${lib.strings.makeBinPath finalAttrs.agePlugins}" "${lib.meta.getExe tofu-age-encryption}"
        touch $out
      '';
    };

  meta = {
    description = "Encrypt OpenTofu state data with age encryption keys";
    homepage = "https://github.com/josh/tofu-age-encryption";
    license = lib.licenses.mit;
    mainProgram = "tofu-age-encryption";
  };
})

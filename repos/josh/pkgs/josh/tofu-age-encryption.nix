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
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tofu-age-encryption";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZshBkONmonMzrwACJtld4to9mrm2HcMRCLF+HJzAW3Q=";
  };

  vendorHash = "sha256-XvKLCghnqUK1T9rflseON/mnoFiJONc/yopyb+cZvKw=";

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
    broken = lib.strings.versionOlder opentofu.version "1.10.0";
  };
})

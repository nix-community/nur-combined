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
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "tofu-age-encryption";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rvSt2QzYG44kAWoJL5xiqfunwVBnLNIYJGXvaomfb20=";
  };

  vendorHash = "sha256-/cORC9k0BtXaChMY0jHwo3fcixeZiZaAkh0xxhGFzII=";

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
        grep --text --quiet "${lib.strings.makeBinPath finalAttrs.agePlugins}" "${lib.getExe tofu-age-encryption}"
        touch $out
      '';
    };

  meta = {
    description = "Encrypt OpenTofu state data with age encryption keys";
    homepage = "https://github.com/josh/tofu-age-encryption";
    license = lib.licenses.mit;
    mainProgram = "tofu-age-encryption";
    platforms = lib.platforms.all;
    broken = lib.strings.versionOlder opentofu.version "1.10.0";
  };
})

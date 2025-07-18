{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
buildGoModule (finalAttrs: {
  pname = "ts-acl-hosts-gen";
  version = "0.2.0-unstable-2025-07-18";

  src = fetchFromGitHub {
    owner = "josh";
    repo = "ts-acl-hosts-gen";
    rev = "bc01bf9a327bfe6cac4d85d99f2792157a3a8862";
    hash = "sha256-7WgU4pM8VE30geKL8LHiUjhZxyugpx3AAjg6VC9VK+U=";
  };

  vendorHash = "sha256-ZkjWGoK+1RP1GsBxz2tuLvTUSMYDLF7U+RURmjjPzC0=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    help =
      runCommand "test-ts-acl-hosts-gen-help" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
        ''
          ts-acl-hosts-gen --help
          touch $out
        '';
  };

  meta = {
    description = "Generate Tailscale hosts policy from existing nodes";
    homepage = "https://github.com/josh/ts-acl-hosts-gen";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "ts-acl-hosts-gen";
  };
})

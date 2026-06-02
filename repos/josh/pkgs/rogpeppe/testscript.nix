{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "testscript";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "rogpeppe";
    repo = "go-internal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JIeEhuqWEGaikAQ1F/mFvtCBmot6tKNv4frhbeewcxk=";
  };

  vendorHash = "sha256-WoRmZbYYpwVVetlxJDjUu9jGgwLXUD3/PnUF6ksUT70=";

  subPackages = [
    "cmd/testscript"
  ];

  doCheck = false;

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=stable" ]; };

  meta = {
    description = "Provides a shell-like test environment that is very nicely tuned for testing Go CLI commands";
    homepage = "https://github.com/rogpeppe/go-internal";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
    mainProgram = "testscript";
  };
})

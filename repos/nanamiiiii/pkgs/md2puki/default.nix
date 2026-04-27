{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule rec {
  pname = "md2puki";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "Nanamiiiii";
    repo = "md2puki";
    rev = "v${version}";
    sha256 = "sha256-TBbZmOzWVn8aw1ROjc6DeyWphxVJaOKqq/tbQ1PCN2M=";
  };

  vendorHash = "sha256-tErz6GXAJv1wf84IV8fezqgLCGAZIrIu52xpkiQNfzc=";

  subPackages = [ "cmd/md2puki" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Markdown to Pukiwiki notation converter";
    homepage = "https://github.com/Nanamiiiii/md2puki";
    mainProgram = "md2puki";
    license = lib.licenses.mit;
  };
}

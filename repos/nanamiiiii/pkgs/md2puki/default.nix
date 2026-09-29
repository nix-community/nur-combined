{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule rec {
  pname = "md2puki";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "Nanamiiiii";
    repo = "md2puki";
    rev = "v${version}";
    sha256 = "sha256-sWw/Z1yt11U7JB12ulnTpyCbzgqbLKEPBJ/6klGu9kY=";
  };

  vendorHash = "sha256-j2XenbE5d8JlJW3eRrFUz4arYYQBtdGIr0sHyKi37a4=";

  subPackages = [ "cmd/md2puki" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Markdown to Pukiwiki notation converter";
    homepage = "https://github.com/Nanamiiiii/md2puki";
    mainProgram = "md2puki";
    license = lib.licenses.mit;
  };
}

{
  emacsPackages,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  ...
}:
# Not on MELPA, and the tree-sitter based mode is unrelated to nixpkgs'
# terraform-mode; pin the rev.
emacsPackages.trivialBuild {
  pname = "terraform-ts-mode";
  version = "0.6-unstable-2026-05-31";

  src = fetchFromGitHub {
    owner = "kgrotel";
    repo = "terraform-ts-mode";
    rev = "28bafd1c56cfeb94c5a3f2acedc3aba2c6a6bc24";
    hash = "sha256-TTcDIxA35h08oFMQr/ichF5ANClqXIcE4NXggYxeZzo=";
  };

  packageRequires = [ ];

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-terraform-ts-mode --version=branch";

  meta = {
    description = "Terraform major mode for Emacs using tree-sitter and eglot";
    homepage = "https://github.com/kgrotel/terraform-ts-mode";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}

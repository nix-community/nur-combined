{
  emacsPackages,
  fetchFromGitHub,
  lib,
  nix-update,
  writeShellScript,
  ...
}:
# vertico-buffer-frame: centered child-frame display for vertico (dmenu-style
# completion). Not on MELPA; pin the rev. Successor of
# vertico-posframe-preview, no private-API advice.
emacsPackages.trivialBuild {
  pname = "vertico-buffer-frame";
  version = "0-unstable-2026-06-12";

  src = fetchFromGitHub {
    owner = "kn66";
    repo = "vertico-buffer-frame";
    rev = "af12d6fe94fa9802dbdcf844a52cb49bd30baa61";
    hash = "sha256-bj1DOw9SV7hk+3cF7KQhfVoRjxEWc9RYw1uEEkfIy38=";
  };

  packageRequires = with emacsPackages; [
    vertico
    consult
  ];

  passthru.updateScript = writeShellScript "update-script.sh" "${lib.getExe nix-update} --flake emacs-vertico-buffer-frame --version=branch";

  meta = {
    description = "Child-frame display for Vertico completions";
    homepage = "https://github.com/kn66/vertico-buffer-frame";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.aciceri ];
    platforms = lib.platforms.all;
  };
}

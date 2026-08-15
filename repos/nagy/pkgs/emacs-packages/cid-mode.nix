{
  lib,
  melpaBuild,
  fetchFromGitHub,
  magit-section,
}:

melpaBuild {
  pname = "cid-mode";
  version = "0-unstable-2026-08-15";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "emacs-ipfs-modes";
    rev = "cf2ef34dbce8173ba0cb03ac82f456bb2ffc7d63";
    hash = "sha256-NXdR0/UP/lYlnYnsGjAZcypErJg0FObzo1g1Vb2X7+4=";
  };

  packageRequires = [
    magit-section
  ];

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/nagy/emacs-ipfs-modes";
    description = "Decode and browse IPFS Content Identifiers from Emacs";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}

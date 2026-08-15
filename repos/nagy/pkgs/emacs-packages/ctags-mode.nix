{
  lib,
  melpaBuild,
  fetchFromGitHub,
  magit-section,
  universal-ctags,
}:

melpaBuild {
  pname = "ctags-mode";
  version = "0-unstable-2026-08-10";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "emacs-ctags-mode";
    rev = "2b720664b45b9071f0fe772db11d5110217c2deb";
    hash = "sha256-Sf2WHjD9lTlHaNqy4pG99DLoOn99FlDzuPE2Z8t6J6c=";
  };

  packageRequires = [
    magit-section
  ];

  postPatch = ''
    substituteInPlace ctags-mode.el \
      --replace-fail 'ctags-program "ctags"' 'ctags-program "${lib.getExe universal-ctags}"'
  '';

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/nagy/emacs-ctags-mode";
    description = "Browse Universal Ctags JSON output in a collapsible magit-section tree";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}

{
  lib,
  melpaBuild,
  fetchFromGitHub,
  stdenv,
}:

let
  # The bruvtab CLI/mediator binary, same flake as modules/firefox.nix.
  bruvtab =
    (builtins.getFlake "github:pschmitt/bruvtab").packages.${stdenv.hostPlatform.system}.bruvtab;
in

melpaBuild {
  pname = "bruvtab";
  version = "0-unstable-2026-08-22";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "emacs-bruvtab";
    rev = "09a9c7f3e244cfa3fb6ee878d7953607063af740";
    hash = "sha256-nHChSQfUvgkWYigwVVGl7zGekei0jR55H066FqOSxKs=";
  };

  # From upstream default.nix: point the `cli' backend at the store path
  # of the bruvtab executable instead of a name looked up on $PATH.
  postPatch = ''
    substituteInPlace bruvtab.el \
      --replace-fail 'bruvtab-program "bruvtab"' 'bruvtab-program "${lib.getExe' bruvtab "bruvtab"}"'
  '';

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/nagy/emacs-bruvtab";
    description = "URL lookup for EXWM Firefox windows via bruvtab";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}

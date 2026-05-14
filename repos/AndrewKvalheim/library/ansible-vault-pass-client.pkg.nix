{ fetchFromGitHub
, lib
, stdenv
, unstableGitUpdater

  # Dependencies
, gopass
, python3
}:

let
  inherit (lib) getExe licenses;
in
stdenv.mkDerivation {
  pname = "ansible-vault-pass-client";
  version = "1.0.1-unstable-2026-03-01";
  meta = {
    description = "Script to integrate Ansible Vault and pass or gopass";
    homepage = "https://github.com/me-vlad/ansible-vault-pass-client";
    license = licenses.mit;
  };

  passthru.updateScript = unstableGitUpdater { };

  src = fetchFromGitHub {
    owner = "me-vlad";
    repo = "ansible-vault-pass-client";
    rev = "e9240197612e4a328ffefd4b5cfb76cb900fa863";
    hash = "sha256-Fz0+Xy63kdrN4XtneUetIStGAMd+Gu8eL/nkQNP53Yk=";
  };

  postPatch = ''
    substituteInPlace 'ansible-vault-pass-client' \
      --replace-fail "'pass'" "'${getExe gopass}'"
  '';

  buildInputs = [
    python3
  ];

  postInstall = ''
    install -D --target-directory "$out/bin" 'ansible-vault-pass-client'
  '';
}

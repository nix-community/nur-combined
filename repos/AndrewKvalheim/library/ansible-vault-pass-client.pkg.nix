{ fetchFromGitHub
, gitUpdater
, lib
, stdenvNoCC

  # Dependencies
, gopass
, python3
}:

let
  inherit (lib) getExe licenses;
in
stdenvNoCC.mkDerivation (ansible-vault-pass-client: {
  pname = "ansible-vault-pass-client";
  version = "1.0.2";
  meta = {
    description = "Script to integrate Ansible Vault and pass or gopass";
    homepage = "https://github.com/me-vlad/ansible-vault-pass-client";
    license = licenses.mit;
  };

  passthru.updateScript = gitUpdater { };

  src = fetchFromGitHub {
    owner = "me-vlad";
    repo = "ansible-vault-pass-client";
    rev = "refs/tags/${ansible-vault-pass-client.version}";
    hash = "sha256-0B70otGbW4iQ4h+okaDiepOOz0uZBUeTMnXOZvO3vYs=";
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
})

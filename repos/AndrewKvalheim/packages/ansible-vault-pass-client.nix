{ fetchFromGitHub
, lib
, stdenv
, unstableGitUpdater

  # Dependencies
, gopass
, python3
}:

stdenv.mkDerivation {
  pname = "ansible-vault-pass-client";
  version = "1.0.1-unstable-2022-04-21";

  src = fetchFromGitHub {
    owner = "me-vlad";
    repo = "ansible-vault-pass-client";
    rev = "14158aa7803ac93801979baf4c6cafd072610e14";
    hash = "sha256-wD7vGXydfiuCAPihAu67sgk1LJzhs/5Jz36h1I7RiAY=";
  };

  postPatch = ''
    substituteInPlace ansible-vault-pass-client \
      --replace-fail "'pass'" "'${gopass}/bin/gopass'"
  '';

  buildInputs = [ python3 ];

  postInstall = ''
    install -D -t $out/bin/ ansible-vault-pass-client
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Script to integrate Ansible Vault and pass or gopass";
    homepage = "https://github.com/me-vlad/ansible-vault-pass-client";
    license = lib.licenses.mit;
  };
}

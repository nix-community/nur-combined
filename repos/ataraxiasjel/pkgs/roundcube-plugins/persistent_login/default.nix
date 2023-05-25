{ roundcubePlugin, lib, fetchFromGitHub, nix-update-script }:

roundcubePlugin rec {
  pname = "persistent_login";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "mfreiholz";
    repo = pname;
    rev = "version-${version}";
    hash = "sha256-q1G3ZjyLmWYZ6lia93Ajbl72rHlrqP4uAEjx63XAx+E=";
  };

  passthru.updateScript = nix-update-script { };
}

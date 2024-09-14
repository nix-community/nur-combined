{
  lib,
  fetchFromGitHub,
  buildGoModule,
  unstableGitUpdater,
}:

buildGoModule rec {
  pname = "go-check";
  version = "0-unstable-2024-09-11";

  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = pname;
    rev = "a7bf31089b3888b70423bb2a1b90eeae7b831c98";
    hash = "sha256-Fk2UsZkNhdKKJ+LJfZKqdjlwlL2wAzxYMZuj+N5I5P4=";
  };

  vendorHash = "sha256-tEUwMiBVpplWR90gPSupQqYvwh3WsC7EPTKuQj0QHZU=";

  subPackages = [ "." ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Check for outdated go module";
    homepage = "https://github.com/Dreamacro/go-check";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}

{ lib, fetchFromGitHub, buildGoModule, nix-update-script }:

buildGoModule rec {
  pname = "go-check";
  version = "unstable-2023-08-27";

  src = fetchFromGitHub {
    owner = "Dreamacro";
    repo = pname;
    rev = "cf9c2d12ef91fdd13d8b997095b3d242a2e003b8";
    hash = "sha256-x5YMzFh6wqDzotjr4Lbwh2nXrtH3ZB+Pk77F+NZ/uS4=";
  };

  vendorHash = "sha256-c70a60qlJNjjBNSXwUp2QSvib/20oWILM4sMEt/PSvc=";

  subPackages = [ "." ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version" "branch" ]; };

  meta = with lib; {
    description = "Check for outdated go module";
    homepage = "https://github.com/Dreamacro/go-check";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}

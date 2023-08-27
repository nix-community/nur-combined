{ lib
, gh
, git
, nix
, nix-update
, python3Packages
}:

python3Packages.buildPythonApplication {
  pname = "update-flake-outputs";
  version = "0.0.1";
  format = "other";

  src = ./.;
  dontBuild = true;

  propagatedBuildInputs = [
    git
    gh
    nix
    nix-update
  ];

  installPhase = ''
    mkdir -p $out/bin
    install main.py $out/bin/update-flake-outputs
  '';

  meta = with lib; {
    description = "A wrapper for nix-update that attempts updating each of a flake's outputs";
    homepage = "https://github.com/SomeoneSerge/pkgs";
    license = licenses.mit;
    maintainers = with maintainers; [ SomeoneSerge ];
  };
}

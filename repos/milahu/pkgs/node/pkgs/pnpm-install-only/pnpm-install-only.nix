{ lib
, pkgs
, fetchFromGitHub
, callPackage
, npmlock2nix
}:

npmlock2nix.build rec {
  pname = "pnpm-install-only";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "pnpm-install-only";
    rev = version;
    hash = "sha256-DZaLQNcM35wqpeYe2gKlCiAjQAgQEr9yfL/gLhqYDU8=";
  };

  # dont run "npm run build"
  buildCommands = [ ];

  installPhase = ''
    mkdir -p $out/opt
    cp -r . $out/opt/$pname
    mkdir $out/bin
    ln -sr $out/opt/$pname/src/index.js $out/bin/$pname
  '';

  node_modules_attrs = {

    # bootstrap npmlock2nix: { symlinkNodeModules = true; } requires pnpm-install-only
    symlinkNodeModules = false;

    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;

    githubSourceHashMap = {
      milahu.nodejs-lockfile-parser.a5d37b98337284df432db75b2d2bd94f066c6b11 = "sha256-V2eT1SoIW96XV45RI8p2ZGqAl5PGrFGllXF07iJeHa8=";
    };

  };

  meta = with lib; {
    description = "Minimal implementation of 'pnpm install'";
    homepage = "https://github.com/milahu/pnpm-install-only";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}


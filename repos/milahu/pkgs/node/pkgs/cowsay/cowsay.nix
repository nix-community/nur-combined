{ lib
, fetchFromGitHub
, npmlock2nix
}:

npmlock2nix.build rec {

  pname = "cowsay";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "piuccio";
    repo = "cowsay";
    rev = "v${version}";
    hash = "sha256-TZ3EQGzVptNqK3cNrkLnyP1FzBd81XaszVucEnmBy4Y=";
  };

  buildCommands = [ "npm run prepare" ];

  installPhase = ''
    mkdir -p $out/opt
    cp -r . $out/opt/cowsay
    mkdir -p $out/bin
    ln -sr $out/opt/cowsay/cli.js $out/bin/cowsay
  '';

  node_modules_attrs = {
    symlinkNodeModules = true;
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;
  };

  meta = with lib; {
    description = "cowsay is a configurable talking cow";
    homepage = "https://github.com/piuccio/cowsay";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ];
  };
}

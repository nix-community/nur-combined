{ pkgs, nodejs, stdenv, lib, ... }:

let

  packageName = with lib; concatStrings (map (entry: (concatStrings (mapAttrsToList (key: value: "${key}-${value}") entry))) (importJSON ./package.json));

  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages."${packageName}".override {
  postInstall = ''
    npm run build
    cp -v dist/*.js $out/
    rm -rf $out/lib
  '';

  meta = with lib; {
    description = "Home Assistant sun card based on Google weather design";
    homepage = "https://github.com/AitorDB/home-assistant-sun-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}


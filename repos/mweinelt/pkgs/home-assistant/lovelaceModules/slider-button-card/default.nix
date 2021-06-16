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
    description = "Lovelace Slider button card";
    homepage = "https://github.com/mattieha/slider-button-card";
    maintainers = with maintainers; [ hexa ];
    license = licenses.mit;
  };
}


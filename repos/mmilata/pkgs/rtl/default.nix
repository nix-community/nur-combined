{ pkgs, nodejs, stdenv, lib, ... }:

let

  packageName = with lib; concatStrings (map (entry: (concatStrings (mapAttrsToList (key: value: "${key}-${value}") entry))) (importJSON ./package.json));

  nodePackages = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in
nodePackages."${packageName}".override {
  nativeBuildInputs = [ pkgs.makeWrapper ];

  postInstall = ''
    makeWrapper '${nodejs}/bin/node' "$out/bin/rtl" \
    --add-flags "$out/lib/node_modules/rtl/rtl.js"
  '';

  meta = with lib; {
    description = "A full function web browser app for LND and C-Lightning";
    maintainers = with maintainers; [ mmilata ];
    license = licenses.mit;
  };
}

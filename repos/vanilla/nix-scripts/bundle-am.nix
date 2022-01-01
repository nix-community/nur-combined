{ pkgs ? import <nixpkgs> { } }:
let am = "arknights-mower"; in
let cmd = ''nix-bundle "(pkgs.callPackage ./. { }).${am}" /bin/${am}''; in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ nix-bundle tree ];
  shellHook = ''
    ${cmd} && filename=$(${cmd})
    cp $filename ${am} && tree
  '';
}

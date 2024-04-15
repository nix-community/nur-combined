{
  outputs = {nixpkgs, ...}: let
    fes = fn:
      builtins.foldl' (a: s: a // {${s} = fn s;}) {} [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
  in {
    packages = fes (system: {
      default = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
        name = "whoops";
        data = builtins.concatStringsSep "" (builtins.genList toString 1024);
        passAsFile = ["data"];
        buildCommand = ''
          line="$( <"$dataPath"; )";
          echo "$line" > "$out";
        '';
      };
      struct = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
        name = "structured-attrs";
        data = builtins.concatStringsSep "" (builtins.genList toString 1024);
        __structuredAttrs = true;
        passAsFile = ["data"];
        buildCommand = ''
          line="$data";
          echo "$line" > "$out";
        '';
      };
    });
  };
}

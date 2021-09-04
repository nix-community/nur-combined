{ lib }: with lib; {
  names = map (c: "base0${toUpper c}") hexChars;
  types = import ./types.nix { inherit lib; };
  shell = import ./shell.nix { inherit lib; };
  #parse = import ./parse.nix { inherit lib; };
  evalScheme = data: (evalModules {
    modules = with base16.types; [
      schemeModule aliasModule templateModule
      data
    ];
  }).config;
}

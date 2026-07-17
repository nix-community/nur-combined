{
  pkgs,
  ...
}:

let
  inherit (pkgs)
    nushell
    writeTextFile
    ;
in
{

  INFINITY = 1.0e308 * 2;

  writeNushellScript =
    let
      shell = "${nushell}/${nushell.shellPath}";
    in
    name: text:
    writeTextFile {
      inherit name;
      executable = true;

      text = ''
        #!${shell}
        ${text}
      '';

      checkPhase = ''
        target=$target ${shell} --no-config-file --no-std-lib --commands 'if not (nu-check --debug $env.target) { exit 1 }'
      '';
    };
}

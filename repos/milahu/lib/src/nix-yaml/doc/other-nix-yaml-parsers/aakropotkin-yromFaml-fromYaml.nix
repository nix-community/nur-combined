# https://github.com/aakropotkin/yromFaml/blob/main/fromYaml.nix

{ lib ? ( builtins.getFlake "nixpkgs" ).lib }:
let

  stripLine = line:
    builtins.head ( builtins.match "([^#]*)(#.*|)" line );

  usefulLine = line: ( builtins.match "[ \\t]*" line ) == null;

  parseString = token:
    let m = builtins.match ''([^"]+|"([^"]*)" *)'' token;
    in if ( m == null ) then ( throw ''YAML string parse failed: "${token}"'' )
       else if ( ( builtins.elemAt m 1 ) != null )
            then ( builtins.elemAt m 1 ) else ( builtins.head m );

  attrLine = line:
    let
      m = builtins.match "([^ :]+): *(.*?) *" line;
      # We may need to dequote the key, since `"key": "value"' is valid.
      name = let nq = builtins.match ''"(.*)"'' ( builtins.head m ); in
             builtins.head ( if ( nq == null ) then m else nq );
      value = parseString ( builtins.elemAt m 1 );
    in if ( m == null ) then ( throw ''YAML parse failed: "${line}"'' )
       else { inherit name value; };

  lines = str:
    builtins.filter usefulLine ( map stripLine ( lib.splitString "\n" str ) );

  fromYaml = str: builtins.listToAttrs ( map attrLine ( lines str ) );

in fromYaml

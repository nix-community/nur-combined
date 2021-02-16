{ pkgs ? import <nixpkgs> {}
}: with pkgs.lib; with builtins; let
  trim = a: head (split "[ \n\t\r]*$" a);
  inline = replaceStrings ["\n"] ["\\n"];
  assertEquals = name: a: b: if a == b then null else throw ''
    ${name}
    expected "${b}"
    but got  "${a}"
  '';
  chisui = import ../../default.nix {};
  test = n: assertEquals "00" 
    (inline (trim (chisui.lib.toJavaPropertiesStr(fromJSON (readFile (toPath ./. + "/test${n}.json"))))))
    (inline (trim (readFile (toPath ./. + "/test${n}.properties"))));
in {
  test00 = test "00";
}


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
  testOut = n: assertEquals "out 00" 
    (inline (trim (chisui.lib.toJavaPropertiesStr(fromJSON (readFile (toPath ./. + "/test${n}.json"))))))
    (inline (trim (readFile (toPath ./. + "/test${n}.properties"))));
  testIn = n: assertEquals "in 00"
    (chisui.lib.fromJavaProperties (readFile (toPath ./. + "/test${n}.properties")))
    (fromJSON (readFile (toPath ./. + "/test${n}.json")));
in {
  out.test00 = testOut "00";
  read.test00 = testIn "00";
}


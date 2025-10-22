{
  fetchFromGitHub,
  ocaml,
  lib
}:
ocaml.overrideAttrs (finalAttrs: prevAttrs: {
  pname = "ocaml+ox";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "oxcaml";
    repo = "oxcaml";
    tag = "5.3.0";
    hash = "sha256-OxvfM0OF1XjtAMgAd+4Lm67iMKV7PD1sFmGPYn/yUBY=";
  };

  meta = prevAttrs.meta // {
    description = "Fast-moving set of extensions to the OCaml programming language";
    longDescription = ''
      OxCaml is both Jane Street’s production compiler, as well as a laboratory for experiments focused towards making OCaml better for performance-oriented programming.

      OxCaml’s primary design goals are:
      * to provide safe, convenient, predictable control over performance-critical aspects of program behavior
      * but only where you need it,
      * and ... in OCaml!
    '';
    homepage = "https://oxcaml.org/";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    maintainers =  with lib.maintainers; [
      ivyfanchiang
    ];
    license = with lib.licenses; [
      lgpl2Only mit
    ];
  };
})

{ pkgs }: with pkgs;

rec {
  fixedWidthStringRight = lib.fixedWidthString;

  fixedWidthStringLeft = width: filler: str:
    let
      strw = lib.stringLength str;
      reqWidth = width - (lib.stringLength filler);
    in
      assert lib.assertMsg (strw <= width)
        "fixedWidthString: requested string length (${
          toString width}) must not be shorter than actual length (${
            toString strw})";
      if strw == width then str else (fixedWidthStringLeft reqWidth filler str) + filler;
}

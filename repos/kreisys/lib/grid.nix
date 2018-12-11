{ pkgs, strings }: with pkgs.lib;

rec {
  rowCount      = grid: length grid;
  colCount      = grid: length (head grid);
  gridElemAt    = grid: row: col: elemAt (elemAt grid row) col;
  gridColAt     = grid: col: genList (row: gridElemAt grid row col) (rowCount grid);
  gridRotate    = grid: genList (gridColAt grid) (colCount grid);
  gridMapRows   = map;
  gridImap0Rows = pkgs.lib.imap0;
  gridImap1Rows = pkgs.lib.imap1;
  gridMapCols   = f: grid: gridRotate (gridMapRows   f (gridRotate grid));
  gridImap0Cols = f: grid: gridRotate (gridImap0Rows f (gridRotate grid));
  gridImap1Cols = f: grid: gridRotate (gridImap1Rows f (gridRotate grid));
  gridMap       = f: grid: gridMapRows (map f) grid;
  gridPmap0     = f: grid: gridImap0Rows (row: val: pkgs.lib.imap0 (f row) val) grid;

  mkGridToString = {
    justifier ? strings.fixedWidthStringRight
  , filler ? " " }: grid: let

    gridAsStrings = gridMap toString grid;
    gridAsLengths = gridMap stringLength gridAsStrings;
    findColWidth  = col: foldl' max 0 (gridColAt gridAsLengths col);

    gridAsPaddedStrings = gridPmap0 (_: col: val: let
      colWidth = findColWidth col;
    in justifier colWidth filler val) gridAsStrings;

  in ''
  ${concatMapStringsSep "\n" (concatStringsSep " ") gridAsPaddedStrings}
  '';

  gridToStringRight = mkGridToString { justifier = strings.fixedWidthStringRight; };
  gridToStringLeft  = mkGridToString { justifier = strings.fixedWidthStringLeft;  };
  gridToString      = gridToStringRight;
}

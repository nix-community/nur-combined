{ pkgs }:

with (import ../. { inherit pkgs; }).grid;

let
  grid = [
    [ 1  2  3  4 ]
    [ 5  6  7  8 ]
    [ 9 10 11 12 ]
  ];

in {
  testGridElemAt = {
    expr     = gridElemAt grid 0 0;
    expected = 1;
  };

  testGridCol = {
    expr     = gridColAt grid 0;
    expected = [ 1 5 9 ];
  };

  testGridRotate = {
    expr = gridRotate grid;

    expected = [
      [ 1 5  9 ]
      [ 2 6 10 ]
      [ 3 7 11 ]
      [ 4 8 12 ]
    ];
  };

  testGridMapRows = {
    expr = gridMapRows (row: [ 0 ] ++ row) grid;

    expected = [
      [ 0  1  2  3  4 ]
      [ 0  5  6  7  8 ]
      [ 0  9 10 11 12 ]
    ];
  };

  testGridImap0Rows = {
    expr = gridImap0Rows (index: row: [ index ] ++ row) grid;

    expected = [
      [ 0  1  2  3  4 ]
      [ 1  5  6  7  8 ]
      [ 2  9 10 11 12 ]
    ];
  };

  testGridImap1Rows = {
    expr = gridImap1Rows (index: row: [ index ] ++ row) grid;

    expected = [
      [ 1  1  2  3  4 ]
      [ 2  5  6  7  8 ]
      [ 3  9 10 11 12 ]
    ];
  };

  testGridMapCols = {
    expr = gridMapCols (col: [ 0 ] ++ col) grid;

    expected = [
      [ 0  0  0  0 ]
      [ 1  2  3  4 ]
      [ 5  6  7  8 ]
      [ 9 10 11 12 ]
    ];
  };

  testGridImap0Cols = {
    expr = gridImap0Cols (index: col: [ index ] ++ col) grid;

    expected = [
      [ 0  1  2  3 ]
      [ 1  2  3  4 ]
      [ 5  6  7  8 ]
      [ 9 10 11 12 ]
    ];
  };

  testGridImap1Cols = {
    expr = gridImap1Cols (index: col: [ index ] ++ col) grid;

    expected = [
      [ 1  2  3  4 ]
      [ 1  2  3  4 ]
      [ 5  6  7  8 ]
      [ 9 10 11 12 ]
    ];
  };

  testGridMap = {
    expr = gridMap (el: el + 1) grid;

    expected = [
      [  2  3  4  5 ]
      [  6  7  8  9 ]
      [ 10 11 12 13 ]
    ];
  };

  testGridPmap0 = {
    expr = gridPmap0 (row: col: val: "(${toString row},${toString col})=${toString val}") grid;

    expected = [
      [ "(0,0)=1"  "(0,1)=2"  "(0,2)=3"  "(0,3)=4"  ]
      [ "(1,0)=5"  "(1,1)=6"  "(1,2)=7"  "(1,3)=8"  ]
      [ "(2,0)=9"  "(2,1)=10" "(2,2)=11" "(2,3)=12" ]
    ];
  };

  testGridToStringRight = {
    expr = gridToStringRight grid;

    expected = ''
    1  2  3  4
    5  6  7  8
    9 10 11 12
    '';
  };

  testGridToStringLeft = let
    inherit (import ../. { inherit pkgs; }) strings;
    gridToStringLeft' = mkGridToString { justifier = strings.fixedWidthStringLeft; filler = "X"; };
  in {
    expr = gridToStringLeft' grid;

    expected = ''
    1 2X 3X 4X
    5 6X 7X 8X
    9 10 11 12
    '';
  };
}

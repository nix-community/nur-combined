{ lib, libSuper }:

let
  # lib imports {{{1
  inherit (lib.lists) #{{{1
    concatLists
    elemAt
    findIndex # (mod)
    foldl'
    foldl1' # (mod)
    genList
    head
    ifoldl' # (mod)
    length
    sublist
    tail
    uniqBy uniq # (mod)
  ; #}}}1
in {

  # findIndex {{{2
  /* Find the index of the first element in the list matching the specified
     predicate or return `default` if no such element exists.

     Type: findIndex :: (a -> bool) -> b -> [a] -> (int | b)

     Example:
       findIndex (x: x > 3) null [ 1 6 4 ]
       => 1
       findFirst (x: x > 9) null [ 1 6 4 ]
       => null
  */
  findIndex =
    # Predicate
    pred:
    # Default value to return
    default:
    # List to search
    list:
    let
      go = i: x:
        if i < 0
          then i
          else if pred x
            then -1 - i
            else i + 1;
      ix = foldl' go 0 list;
    in if ix >= 0 then default else -1 - ix;

  # foldl1' {{{2
  foldl1' =
    f:
    xs:
    foldl' f (head xs) (tail xs);

  # ifoldl' {{{2
  /* Strict version of `ifoldl`.

     The difference is that evaluation is forced upon access. Usually used
     with small whole results (in contrast with lazily-generated list or large
     lists where only a part is consumed.)

     Type: foldl' :: (b -> int -> a -> b) -> b -> [a] -> [ int b ]

     Example:
       ifoldl' (b: i: a: "${b} ${a}-${i}") "z" [ "a" "b" "c" ]
       => [ 3 "z a-0 b-1 c-2" ]
  */
  ifoldl' =
    # Operator to apply
    op:
    # Initial accumulator value
    nul:
    # List to fold over
    list:
    foldl'
      (b: let i = elemAt b 1; in [ (i + 1) (op (elemAt b 0) i) ])
      [ 0 nul ]
      list;

  # uniqBy [uniq] {{{2
  /* Remove duplicate adjacent elements from the list, using the supplied
     equality predicate.

     Type: uniqBy :: (a -> a -> bool) -> [a] -> [a]

     Example:
       uniqBy (x: y: x == y) [ 1 2 2 3 1 1 3 1 1 2 ]
       => [ 1 2 3 1 3 1 2 ]
   */
  uniqBy = 
    # Equality predicate to call
    pred:
    let
      # runs: [{ start = ix; len = ix - start; }]
      go = { runs, ix, ... } @ acc: elem:
        let
          ix' = ix + 1;
          prevElem = acc.elem;
          inherit (acc) start;
        in
        if ix != 0 && pred prevElem elem
          # equal elements
          then if acc ? start
            # end the run
            then let runs' = runs ++ [ { inherit start; len = ix - start; } ];
              in { inherit elem; runs = runs'; ix = ix'; }
            # no run to end
            else { inherit runs elem; ix = ix'; }
          # differing elements
          else { inherit runs elem; ix = ix'; start = acc.start or ix; };
    in
    # List to filter
    list:
    let
      runsAcc = foldl' go { runs = [ ]; ix = 0; } list;
      finalStart = runsAcc.start;
      finalIx = runsAcc.ix;
      finalRun = { start = finalStart; len = finalIx - finalStart; };
      rawRuns = runsAcc.runs;
      runs = if runsAcc ? start then rawRuns ++ [ finalRun ] else rawRuns;
    in concatLists (map ({ start, len }: sublist start len list) runs);

  # uniq {{{3
  /* Remove duplicate adjacent elements from the list.

     Type: uniq :: [a] -> [a]

     Example:
       uniq [ 1 2 2 3 1 1 3 1 1 2 ]
       => [ 1 2 3 1 3 1 2 ]
   */
  uniq = uniqBy (x: y: x == y);

  #}}}1

}
# vim:fdm=marker:fdl=1

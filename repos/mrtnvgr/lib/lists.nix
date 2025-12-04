{ pkgs, numbers }: {
  crampPad = count: default: list: let
    inherit (pkgs.lib) take length replicate;

    cramped = take count list;

    padCount = numbers.relu (count - (length cramped));
  in cramped ++ (replicate padCount default);
}

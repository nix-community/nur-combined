{ pkgs, numbers }: {
  crampPad = count: default: list: let
    inherit (pkgs.lib) take len replicate;

    cramped = take count list;

    padCount = numbers.relu (count - (len cramped));
  in cramped ++ (replicate padCount default);
}

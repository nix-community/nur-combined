{ lib, ... }:
{
  listOfLines =
    {
      comments ? true,
      inlineComments ? true,
      trim ? true,
      removeEmpty ? true,
    }:
    lines:
    let
      pipeline = [
        (lib.splitString "\n")
        (
          list:
          if (builtins.length list) == 0 then
            list
          else if (lib.last list) == "" then
            lib.dropEnd 1 list
          else
            list
        )
      ]
      ++ lib.optional inlineComments (map (s: builtins.head (lib.splitString "#" s)))
      ++ lib.optional trim (map lib.trim)
      ++ lib.optional comments (builtins.filter (s: (builtins.substring 0 1 s) != "#"))
      ++ lib.optional removeEmpty (builtins.filter (s: s != ""));
    in
    lib.pipe lines pipeline;
}

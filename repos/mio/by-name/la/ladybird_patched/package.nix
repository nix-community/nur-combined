{
  ladybird,
}:

ladybird.overrideAttrs (old: {
  pname = "ladybird_patched";

  patches = (old.patches or [ ]) ++ [
    # Built-in "YT Mirror" user script (ported from the Chrome extension) injected
    # into YouTube documents by the WebContent process. See the patch for details.
    ./0001-yt-mirror-builtin-user-script.patch
  ];
})

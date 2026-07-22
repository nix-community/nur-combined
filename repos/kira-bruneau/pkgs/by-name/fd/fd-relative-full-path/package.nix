{ fd, ... }:

fd.overrideAttrs (attrs: {
  patches = (attrs.patches or [ ]) ++ [
    # Use relative path for --full-path
    # See https://github.com/sharkdp/fd/issues/839
    ./relative-full-path.patch
  ];

  checkFlags = (attrs.checkFlags or [ ]) ++ [
    "--skip=test_full_path"
  ];
})

{ jackett }:

(jackett.overrideAttrs (upstream: {
  # 2022-07-29: check phase segfaults on arm (with or without my patches)
  doCheck = false;
  patches = (upstream.patches or []) ++ [
    # bind to an IP address which is usable behind a netns
    ./01-fix-bind-host.patch
  ];
}))


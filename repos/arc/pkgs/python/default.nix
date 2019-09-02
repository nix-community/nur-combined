psuper: {
  hangups = import ./hangups.nix;
  mautrix-python = import ./mautrix-python.nix;
  readlike = import ./readlike.nix;
  reparser = import ./reparser.nix;
  tasklib = import ./tasklib.nix;
  matrix-nio = import ./matrix-nio.nix;
  olm = import ./olm.nix;
  weechat-matrix = import ./weechat-matrix.nix;
  vit = import ./vit.nix;
  urwid1 = import ./urwid1.nix;

  # Updates for packages broken by pytest 5
  flask = { pythonPackages }: with pythonPackages; psuper.flask.overrideAttrs (old: rec {
    version = "1.0.4";
    src = fetchPypi {
      inherit (old) pname;
      inherit version;
      sha256 = "ed1330220a321138de53ec7c534c3d90cf2f7af938c7880fc3da13aa46bf870f";
    };
  });
  h11 = { pythonPackages, fetchpatch }: psuper.h11.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      (fetchpatch {
        url = https://github.com/python-hyper/h11/commit/241e220493a511a5f5a5d472cb88d72661a92ab1.patch;
        sha256 = "1s3ipf9s41m1lksws3xv3j133q7jnjdqvmgk4sfnm8q7li2dww39";
      })
    ];
  });
}

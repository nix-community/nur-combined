self: super:
{
  mosh = super.mosh.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      ./unset-tty.patch
    ];
  });
}

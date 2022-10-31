final: prev:
{
    shntool24wav = prev.shntool.overrideAttrs ( old: rec {
      patches = (old.patches or []) ++ [ ./patches/shnsplit_24.patch ];
    });
}

{
  sources,
  lib,
  stdenv,
  attic-server,
}:
attic-server.overrideAttrs (old: {
  postPatch =
    (old.postPatch or "")
    + ''
      sed -i "/x-id/d" $cargoDepsCopy/aws-sdk-s3-*/src/operation/*.rs
    '';

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
  };
})

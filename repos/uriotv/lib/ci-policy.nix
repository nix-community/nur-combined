# Build permission and redistribution permission are deliberately independent.
# This is a conservative metadata policy, not a substitute for a license audit.
{
  redistributable =
    license:
    let
      licenses = if builtins.isList license then license else [ license ];
      allowed = item: builtins.isAttrs item && (item.redistributable or (item.free or false)) == true;
    in
    licenses != [ ] && builtins.all allowed licenses;
}

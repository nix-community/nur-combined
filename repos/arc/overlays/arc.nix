self: super:
  if super.arc.path or null == ../.
  then { } # avoid unnecessary duplication/reoverlay
  else import ../top-level.nix self super

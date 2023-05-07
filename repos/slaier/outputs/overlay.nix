{ super, lib, ... }:
with lib; composeManyExtensions (attrValues super.overlays)

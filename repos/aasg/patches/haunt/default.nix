{ haunt }:

haunt.overrideAttrs (oldAttrs: rec {
  patches = [ ./restore-raw.patch ];
})

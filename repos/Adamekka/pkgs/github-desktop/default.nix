{ github-desktop, maintainer }:

github-desktop.overrideAttrs (oldAttrs: {
  meta = oldAttrs.meta // {
    maintainers = [ maintainer ];
  };
  patches = (oldAttrs.patches or [ ]) ++ [ ./linux-oauth-callback.patch ];
})

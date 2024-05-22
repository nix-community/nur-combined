{ kwin }:

kwin.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches ++ [ ./5511-backport_linux-drm-syncobj-v1_support.patch ];
})

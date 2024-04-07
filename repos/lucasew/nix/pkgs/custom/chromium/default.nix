{
  ccacheStdenv,
  chromium,
  lib,
}:

chromium.browser.overrideDerivation (old: {
  # stdenv = ccacheStdenv;
  patchPhase = null;
  postPatch = (old.patchPhase or "") + (old.postPatch or "");
  patches = (old.patches or [ ]) ++ [ ./hide-tabs.patch ];
})

final: prev: {
  # matrix-js-sdk decides which spec features a server has by looking for the
  # exact version that stabilised each one in /versions. continuwuity lists
  # v1.11 but not v1.10, so element thinks sv.mt can't do recursive
  # /relations and falls back to inserting thread reactions/edits as non-live
  # events. That leaves the open thread view one event behind, so the next
  # reply doesn't show until the thread is reopened. A later minor version
  # implies the earlier one's features, so count those too.
  # https://forgejo.ellis.link/continuwuation/continuwuity/issues/2350
  element-web-unwrapped = prev.element-web-unwrapped.overrideAttrs (oldAttrs: {
    preBuild = (oldAttrs.preBuild or "") + ''
      patch -p1 -d "$(realpath apps/web/node_modules/matrix-js-sdk)" < ${./feature-version-or-later.patch}
    '';
  });
}

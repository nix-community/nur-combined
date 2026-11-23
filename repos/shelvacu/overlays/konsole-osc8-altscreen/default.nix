final: prev: {
  # backport of https://invent.kde.org/utilities/konsole/-/commit/962f359cf and https://invent.kde.org/utilities/konsole/-/merge_requests/1325
  kdePackages = prev.kdePackages.overrideScope (
    kfinal: kprev: {
      konsole =
        if kprev.konsole.version == "26.04.3" then
          kprev.konsole.overrideAttrs (oldAttrs: {
            patches = (oldAttrs.patches or [ ]) ++ [ ./osc8-altscreen.patch ];
          })
        else
          kprev.konsole;
    }
  );
}

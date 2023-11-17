{
  makeSetupHook,
  nodePackages,
}: {
  firefoxExtensionBuildHook =
    makeSetupHook
    {
      name = "firefox-extension-build-hook";
      substitutions.webExt = "${nodePackages.web-ext}/bin/web-ext";
    }
    ./firefox-extension-build-hook.sh;

  firefoxExtensionInstallHook =
    makeSetupHook
    {
      name = "firefox-extension-install-hook";
    }
    ./firefox-extension-install-hook.sh;
}

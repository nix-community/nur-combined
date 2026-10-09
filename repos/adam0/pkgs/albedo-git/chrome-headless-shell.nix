{
  # keep-sorted start
  playwright-driver,
  runCommand,
  stdenv,
  # keep-sorted end
}: let
  directories = {
    # keep-sorted start
    aarch64-darwin = "chrome-headless-shell-mac-arm64";
    aarch64-linux = "chrome-headless-shell-linux-arm64";
    x86_64-linux = "chrome-headless-shell-linux64";
    # keep-sorted end
  };
  browser = playwright-driver.components.chromium-headless-shell;
  browserVersion = playwright-driver.browsersJSON.chromium-headless-shell.browserVersion;
in
  runCommand "chrome-headless-shell-${browserVersion}" {} ''
    mkdir -p $out/bin
    ln -s ${browser}/${directories.${stdenv.hostPlatform.system}}/chrome-headless-shell $out/bin/chrome-headless-shell
  ''

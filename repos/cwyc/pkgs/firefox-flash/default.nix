{python3Packages, firefox-esr, writeScript, wrapFirefox, selinux-sandbox, stdenv, lib, ...}:
# firefox-esr is unwrapped?
let
  wrapped = wrapFirefox firefox-esr {
    cfg.enableAdobeFlash=true;
  };

  launcher = writeScript "firefox-flash" ''
    #!/usr/bin/env bash
    DATADIR=''${XDG_DATA_HOME:-$HOME/.local/share/firefox-flash-sandbox}
    mkdir -p $DATADIR/tmp
    mkdir -p $DATADIR/home
    ${selinux-sandbox}/bin/sandbox -X -H $DATADIR/home -T $DATADIR/tmp ${wrapped}/bin/firefox
  '';

  sandbox = selinux-sandbox.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [python3Packages.libselinux];
    propagatedBuildInputs = old.propagatedBuildInputs ++ [python3Packages.libselinux];
  });
in
  stdenv.mkDerivation {
    name="firefox-flash-sandbox";
    version="78-esr";
    buildInputs = [sandbox];
    builder = writeScript "builder.sh" ''
      source $stdenv/setup

      mkdir -p $out/bin
      cp ${launcher} $out/bin/firefox-flash-sandbox
      chmod +x $out/bin/firefox-flash-sandbox

         mkdir -p $out/share/applications/
      cp ${./firefox-flash-sandbox.desktop} $out/share/applications/firefox-flash-sandbox.desktop
    '';
    meta = {
      description = "Firefox with flash enabled and behind a selinux sandbox, for playing old flash games without risking your everyday browser.";
      platforms = with stdenv.lib.platforms; [ linux ];
      broken = true;
    };
  }
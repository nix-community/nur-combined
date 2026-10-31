{
  firefox-unwrapped,
  lib,
  stdenv,
  wrapFirefox,
}:
let
  package = firefox-unwrapped.overrideAttrs (old: {
    __structuredAttrs = true;
    strictDeps = true;
    patches = (old.patches or [ ]) ++ [
      ./0001-juggler.patch
      ./0002-browser.patch
      ./0003-docshell.patch
      ./0004-dom.patch
      ./0005-intl.patch
      ./0006-js.patch
      ./0007-layout.patch
      ./0008-modules.patch
      ./0009-netwerk.patch
      ./0010-build-system.patch
      ./0011-toolkit.patch
      ./0012-uriloader.patch
      ./0013-widget.patch
      ./0014-xpcom.patch
      ./0015-devtools.patch
      ./0016-remote.patch
      ./0017-third-party.patch
      ./0018-xpfe.patch
      ./0019-security.patch
    ];

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Firefox with anti fingerprinting modifications";
      homepage = "https://github.com/feder-cr/firefox_antidetect_patch";
      platforms = lib.platforms.unix;
      broken = stdenv.buildPlatform.is32bit;
      maxSilent = 21600; # 6h for PGO build (c.f. #129212, #129115)
      license = lib.licenses.mpl20;
      mainProgram = "firefox";
    };
  });
in
package
// {
  wrapped = wrapFirefox package { };
}

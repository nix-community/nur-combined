{
  stdenv,
  nixpkgsPath,
  firefox-common,
  fetchFromGitHub,
  libnotify,
}:
let
  gitVersion = "2020.06-current";
  waterfox-unwrapped-base =
    (firefox-common {
      pname = "waterfox";
      ffversion = "68.0-${gitVersion}";
      src = fetchFromGitHub {
        owner = "MrAlex94";
        repo = "Waterfox";
        rev = "dce288a7f9b1e1ccd57f03f35d91b93519c87847";
        sha256 = "1p6agl0dvvf3qrnwjc9j3nh662i9432bwr6q5rry48a9z9l7zk26";
      };
      patches = [
        (nixpkgsPath + /pkgs/applications/networking/browsers/firefox/no-buildconfig-ffx65.patch)
      ];
      extraConfigureFlags = [
        "--enable-content-sandbox"
        "--with-app-name=waterfox"
        "--with-app-basename=Waterfox"
        "--with-branding=browser/branding/waterfox"
        "--with-distribution-id=net.waterfox"
      ];
      extraMakeFlags = [
        "-s"
      ];
      meta = with stdenv.lib; {
        description = "A web browser designed for privacy and user choice";
        longDescription = ''
          The Waterfox browser is a specialised modification of the Mozilla
          platform, designed for privacy and user choice in mind.

          Other modifications and patches that are more upstream have been
          implemented as well to fix any compatibility/security issues that Mozilla
          may lag behind in implementing (usually due to not being high priority).
          High request features removed by Mozilla but wanted by users are retained
          (if they aren't removed due to security).
        '';
        homepage = "https://www.waterfoxproject.org";
        maintainers = with maintainers; [ arobyn ];
        platforms = [ "x86_64-linux" ];
        license = licenses.mpl20;
        longBuild = true; # Takes more than Travis' 50min build timeout to complete
      };
    }).overrideAttrs
      (oa: {
        hardeningDisable = [ "format" ]; # -Werror=format-security
      });
in
waterfox-unwrapped-base.overrideAttrs (
  oa:
  let
    binaryName = "waterfox";
    browserName = binaryName;
    execdir = "/bin";
  in
  {
    preConfigure = oa.preConfigure + ''
      echo "MOZ_REQUIRE_SIGNING=0" >> $MOZCONFIG
      echo "MOZ_ADDON_SIGNING=0" >> $MOZCONFIG
      echo "ac_add_options \"MOZ_ALLOW_LEGACY_EXTENSIONS=1\"" >> $MOZCONFIG
    '';
    postInstall = ''
      # Remove SDK cruft. FIXME: move to a separate output?
      rm -rf $out/share/idl $out/include $out/lib/${binaryName}-devel-*
      libDir=$out/lib/${binaryName}

      # Needed to find Mozilla runtime
      gappsWrapperArgs+=(--argv0 "$out/bin/.${binaryName}-wrapped")
    '';
    postFixup = ''
      # Fix notifications. LibXUL uses dlopen for this, unfortunately; see #18712.
      patchelf --set-rpath "${stdenv.lib.getLib libnotify}/lib:$(patchelf --print-rpath "$out"/lib/${binaryName}*/libxul.so)" \
          "$out"/lib/${binaryName}*/libxul.so
    '';
    installCheckPhase = ''
      # Some basic testing
      "$out${execdir}/${browserName}" --version
    '';
  }
)

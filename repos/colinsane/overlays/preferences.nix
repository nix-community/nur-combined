# personal preferences
# prefer to encode these in `sane.programs`
# resort to this method for e.g. system dependencies, or things which are referenced from too many places.
(self: super:
with self;
let
  # XXX(2025-02-08): `nix-build -A hosts.desko.pkgs.bunpen` FAILS (`nix-build -A pkgs.bunpen`, meanwhile, PASSES!)
  # this is some weird cross thing, where `pkgs.gnu64.stdenv` != `hosts.desko.pkgs.gnu64.stdenv`,
  # and this impacts hare because hare forces cross compilation always.
  #
  # the patch here ASSUMES THE BUILD MACHINE IS x86, and it works by forcing cc/bintools to be built as native packages, not gnu64 cross packages.
  # TODO: this is a hack and can hopefully be someday removed!

  # x86_64PkgsCrossToolchain = pkgs.pkgsBuildBuild;
  # hare = pkgs.pkgsBuildTarget.hare.override {
  #   inherit x86_64PkgsCrossToolchain;
  # };
  # crossHareHook = pkgs.hareHook.override {
  #   inherit hare;
  # };
in
{
  # DISABLE HDCP BLOB in pinephone pro.
  # this is used by u-boot; requires redeploying the bootloader (the SPL, specifically).
  # i can see that nixpkgs does process this option, but the hash of bl31.elf doesn't actually change
  arm-trusted-firmware = super.arm-trusted-firmware.override {
    unfreeIncludeHDCPBlob = false;
  };

  # beam = super.beam.override {
  #   # build erlang without webkit (for servo)
  #   wxGTK32 = wxGTK32.override {
  #     withWebKit = false;
  #   };
  # };

  # bonsai = super.bonsai.override {
  #   hareHook = crossHareHook;
  # };
  # bunpen = super.bunpen.override {
  #   hareHook = crossHareHook;
  # };

  # XXX(2024-12-26 - 2025-04-30): prefer pre-built electron because otherwise it takes 4 hrs to build from source.
  # but wait 2 days after staging -> master merge, and normal electron should be cached and safe to remove
  electron = electron-bin;
  electron_33 = electron_33-bin;
  electron_34 = electron_34-bin;
  electron_35 = electron_35-bin;

  # evolution-data-server = super.evolution-data-server.override {
  #   # OAuth depends on webkitgtk_4_1: old, forces an annoying recompilation
  #   enableOAuth2 = false;
  # };
  # evolution-data-server-gtk4 = super.evolution-data-server-gtk4.override {
  #   # avoid webkitgtk_6_0 build. lol.
  #   withGtk4 = false;
  # };

  # ffmpeg = super.ffmpeg.override {
  #   # required by mpv for spatial audio; enable it globally to avoid shipping many ffmpegs
  #   # or maybe not: this forces a recompilation of many expensive packages, incl libreoffice and *webkitgtk*.
  #   #   not needed, because *pipewire* does the downmixing.
  #   #   PW uses ffmpeg-headless; not affected by `ffmpeg.override`. it directly calls into `libmysofa`
  #   withMysofa = true;
  # };
  # ffmpeg-full = super.ffmpeg-full.override {
  #   # saves 20 minutes of build time and cross issues, for unused feature
  #   withSamba = false;
  # };

  go2tv = super.go2tv.overrideAttrs (upstream: {
    # XXX(2025-02-12): with release 1.18.0 (due to a4cd63f512), listing devices gives error (even with UDP 1900 whitelisted in firewall):
    # > Encountered error(s): checkflags error: checkTflag service loading error: loadSSDPservices: No available Media Renderers
    # this would apparently be because many UPnP servers do not respond to requests _from_ port 1900.
    # still present in 1.18.1.
    #
    # a commit to gssdp (177f2772cf) suggests this is due to "security reasons" (perhaps it allows neighbors to hole-punch port 1900 of clients?)
    # although it itself responds perfectly fine to M-SEARCH requests from port 1900.
    # "DLNA requirement 7.2.3.4" could shed some light, but it's a private spec.
    # so just don't use port 1900 for now.
    #
    # done as overlay instead of in hosts/common/programs/go2tv.nix so that python consumers like sane-cast also get this fix.
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace devices/devices.go --replace-fail "port := 1900" "port := 1901"

      # by default, go2tv passes `ffmpeg -re`, which limits ffmpeg to never stream faster than realtime.
      # patch that out to let the receiver stream as fast as it wants.
      # maybe not necessary, was added during debugging.
      substituteInPlace soapcalls/utils/transcode.go --replace-fail '"-re",' ""
    '';

    patches = (upstream.patches or []) ++ [
      (fetchpatch {
        name = "enable ffmpeg functionality outside the GUI paths";
        url = "https://git.uninsane.org/colin/go2tv/commit/9afa10dd2e2ef16def26be07eb72fbc5b0382ddd.patch";
        hash = "sha256-PW989bb/xHk7EncZ3Ra69y2p1U1XeePKq2h7v5O47go=";
      })
      (fetchpatch {
        # this causes it to advertize that weird `video/vnd.dlna.mpeg-tts` MIME type.
        # TODO: try `video/mpeg`.
        # the following were tried, and failed:
        # - video/mp2t
        # - video/x-mpegts
        # - video/MP2T
        name = "advertise the correct MediaType when transcoding";
        url = "https://git.uninsane.org/colin/go2tv/commit/3bbb98318df2fc3d1a61cecd2b06d1bec9964651.patch";
        hash = "sha256-9n43QXfCWyEn5qw1rWnmFb8oTY6xgkih5ySAcxdBVZo=";
      })
    ];
  });

  # gnome-control-center = super.gnome-control-center.override {
  #   # i build goa without the "backend", to avoid webkit_4_1.
  #   # however gnome-control-center *directly* uses goa-backend because it manages the accounts...
  #   # so if you really need gnome-control center, then here we are, re-enabling the goa backend.
  #   gnome-online-accounts = gnome-online-accounts.override {
  #     enableBackend = true;
  #   };
  # };
  # gnome-online-accounts = super.gnome-online-accounts.override {
  #   # disables the upstream "goabackend" feature -- presumably "Gnome Online Accounts Backend"
  #   # frees us from webkit_4_1, in turn.
  #   # XXX(2024-11-19): gnome-online-accounts no longer depends on webkitgtk at all ??
  #   enableBackend = false;
  #   # gvfs = super.gvfs.override {
  #   #   # saves 20 minutes of build time and cross issues, for unused feature
  #   #   samba = null;
  #   # };
  # };

  # gvfs = super.gvfs.override {
  #   # saves 20 minutes of build time and cross issues, for unused feature
  #   samba = null;
  # };

  # haredoc = super.haredoc.override {
  #   hareHook = crossHareHook;
  # };
  # hareThirdParty = super.hareThirdParty.overrideScope (sself: ssuper: {
  #   hare-ev = (ssuper.hare-ev.override {
  #     hareHook = crossHareHook;
  #   }).overrideAttrs { doCheck = false; };
  #   hare-json = (ssuper.hare-json.override {
  #     hareHook = crossHareHook;
  #   }).overrideAttrs { doCheck = false; };
  # });

  # hare = pkgsBuildTarget.hare.override {
  #   x86_64PkgsCrossToolchain = super.pkgsBuildBuild;
  # };

  # hareHook = super.hareHook.override {
  #   hare = pkgsBuildTarget.hare.override {
  #     x86_64PkgsCrossToolchain = pkgsBuildBuild;
  #   };
  # };

  # phog = super.phog.override {
  #   # disable squeekboard because it takes 20 minutes to compile when emulated
  #   squeekboard = null;
  # };

  # rsyslog = super.rsyslog.override {
  #   # XXX(2024-07-28): required for cross compilation
  #   withGcrypt = false;
  # };

  # swaynotificationcenter = super.swaynotificationcenter.override {
  #   gvfs = gvfs.override {
  #     # saves 20 minutes of build time and cross issues, for unused feature
  #     samba = null;
  #   };
  # };

  # 2023/12/10: zbar barcode scanner: used by megapixels, frog.
  # the video component does not cross compile (qt deps), but i don't need that.
  zbar = super.zbar.override { enableVideo = false; };
})

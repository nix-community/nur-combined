# personal preferences
# prefer to encode these in `sane.programs`
# resort to this method for e.g. system dependencies, or things which are referenced from too many places.
self: super:
{

  # DISABLE HDCP BLOB in pinephone pro (and every other ATF build)
  # this is used by u-boot; requires redeploying the bootloader (the SPL, specifically).
  # i can see that nixpkgs does process this option, but the hash of bl31.elf doesn't actually change
  arm-trusted-firmware = super.arm-trusted-firmware.override {
    unfreeIncludeHDCPBlob = false;
  };

  # XXX(2026-02-16): does not apply; i haven't made use of this in several months
  # go2tv = super.go2tv.overrideAttrs (upstream: {
  #   postPatch = (upstream.postPatch or "") + ''
  #     # by default, go2tv passes `ffmpeg -re`, which limits ffmpeg to never stream faster than realtime.
  #     # patch that out to let the receiver stream as fast as it wants.
  #     # maybe not necessary, was added during debugging.
  #     substituteInPlace soapcalls/utils/transcode.go --replace-fail '"-re",' ""
  #   '';

  #   patches = (upstream.patches or []) ++ [
  #     (self.fetchpatch {
  #       name = "enable ffmpeg functionality outside the GUI paths";
  #       url = "https://git.uninsane.org/colin/go2tv/commit/9afa10dd2e2ef16def26be07eb72fbc5b0382ddd.patch";
  #       hash = "sha256-PW989bb/xHk7EncZ3Ra69y2p1U1XeePKq2h7v5O47go=";
  #     })
  #     (self.fetchpatch {
  #       # this causes it to advertize that weird `video/vnd.dlna.mpeg-tts` MIME type.
  #       # TODO: try `video/mpeg`.
  #       # the following were tried, and failed:
  #       # - video/mp2t
  #       # - video/x-mpegts
  #       # - video/MP2T
  #       name = "advertise the correct MediaType when transcoding";
  #       url = "https://git.uninsane.org/colin/go2tv/commit/3bbb98318df2fc3d1a61cecd2b06d1bec9964651.patch";
  #       hash = "sha256-9n43QXfCWyEn5qw1rWnmFb8oTY6xgkih5ySAcxdBVZo=";
  #     })
  #   ];
  # });

  yt-dlp = let
    # XXX(2026-02-04): yt-dlp accepts one of 4 JS runtimes, in order:
    # - deno
    # - nodejs
    # - quickjs (a.k.a. quickjs-ng)
    # - bun
    # nixpkgs allows providing any of these simply by overriding the `deno` callpackage argument,
    # but yt-dlp only actually checks for `deno` unless configured otherwise
    # - e.g. via patching (below)
    # - e.g. via `--js-runtimes node` CLI argument (or added to ~/.config/yt-dlp/config)
    #
    # jsRuntime = final.deno;  #< 2026-02-04: doesn't cross compile, nor build for musl
    jsRuntime = self.nodejs;
    # jsRuntime = final.quickjs-ng;
    # jsRuntime = final.bun;  #< 2026-02-04: doesn't cross compile
    jsRuntimeYtdlpName = {
      deno = "deno";
      node = "node";
      qjs = "quickjs";
      bun = "bun";
    }.${jsRuntime.meta.mainProgram};
  in (super.yt-dlp.override {
    deno = jsRuntime;
  }).overrideAttrs (upstream: {
    postPatch = (upstream.postPatch or "") + ''
      substituteInPlace yt_dlp/YoutubeDL.py \
        --replace-fail \
          "self.params.get('js_runtimes', {'deno': {}})" \
          "self.params.get('js_runtimes', {'${jsRuntimeYtdlpName}': {}})"
      substituteInPlace yt_dlp/options.py \
        --replace-fail \
          "default=['deno']" \
          "default=['${jsRuntimeYtdlpName}']"
    '';
  });
}

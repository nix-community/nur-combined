# mostly here for testing.
# megapixels branching is weird, and their stable releases are cut from a commit which diverged well over a year ago IIRC.
# state as of 2024-09-10 (megapixels-next unstable-2024-05-11):
# - when run against linux-postmarketos-allwinner: renders camera preview image, but crashes on save.
# state as of 2024-09-10 (megapixels-next unstable-2024-09-03):
# - when run against linux-postmarketos-allwinner: renders camera preview image, appears to take photo, but cannot find it on disk.
#   - Failed to spawn postprocess process: failed to execute child process "/nix/store/...-megapixels-next/share/megapixels/postprocess.sh" (No such file or directory)
#   hangs/crashes after tabbing away
# - when run against linux mainline: launch hangs at "[libmegapixels] ".
#   i seem to recall this from 2024-05-11: the patch i disabled during the megapixels-next update to 2024-09-03 was a memory safety issue,
#   which was causing a crash during the error message printing. so rebasing that would get me an error message, but still no fix.
{ config, pkgs, ... }:
let
  cfg = config.sane.programs.megapixels-next;
in
{
  sane.programs.megapixels-next = {
    packageUnwrapped = pkgs.megapixels-next.overrideAttrs (base: {
      postPatch = (base.postPatch or "") + ''
        # 2024/04/21:
        # 1. patch to save photos in a more specific directory (process_pipeline.c:process_capture_burst)
        # 2. patch so folder button works (main.c:run_open_photos_action)
        substituteInPlace src/process_pipeline.c src/main.c \
          --replace-fail 'g_get_user_special_dir(G_USER_DIRECTORY_PICTURES)' 'getenv("XDG_PHOTOS_DIR")'
      '';
      # rename things so i can have `megapixels` and `megapixels-next` co-installed
      postInstall = (base.postInstall or "") + ''
        ln -s $out/bin/megapixels $out/bin/megapixels-next

        substituteInPlace $out/share/applications/me.gapixels.Megapixels.desktop \
          --replace-fail "Exec=megapixels" "Exec=$out/bin/megapixels" \
          --replace-fail "Name=Megapixels" "Name=Megapixels-Next"
      '';

      meta = (base.meta or {}) // {
        # give weaker priority to ourselves, to avoid shadowing `megapixels` exe name
        # if co-installed with stock `megapixels`
        priority = ((base.meta or {}).priority or 0) + 1;
      };
    });

    # this sandboxing was derived from original megapixels: possibly inaccurate
    sandbox.wrapperType = "inplace";  #< for share/megapixels/movie.sh
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  #< so that it can open the image viewer using fdo portal...
    sandbox.extraHomePaths = [
      # ".config/megapixels"
      "Pictures/Photos"
      # also it addresses a lot via relative path.
    ];
    sandbox.extraPaths = [
      # it passes the raw .dng files to a post-processor, via /tmp
      "/tmp"
      "/sys/class/leds"  #< for flash, presumably
    ];
    sandbox.whitelistAvDev = true;
    sandbox.mesaCacheDir = ".cache/megapixels/mesa";  # TODO: is this the correct app-id?
    gsettings."me/gapixels/megapixels" = {
      # **required** for it to find its postprocess script
      postprocessor = "${cfg.package}/share/megapixels/postprocess.sh";
      save-raw = false;
    };
    gsettings."org/sigxcpu/feedbackd/application/me-gapixels-megapixels" = {
      # optional, to disable shutter sound
      profile = "silent";
    };

    env.CAMERA = "me.gapixels.Megapixels.desktop";
  };
}

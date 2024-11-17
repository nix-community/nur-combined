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
{ pkgs, ... }:
{
  sane.programs.megapixels-next = {
    packageUnwrapped = pkgs.megapixels-next.overrideAttrs (base: {
      # rename things so i can have `megapixels` and `megapixels-next` co-installed
      postInstall = (base.postInstall or "") + ''
        mv $out/bin/megapixels $out/bin/megapixels-next

        substituteInPlace $out/share/applications/me.gapixels.Megapixels.desktop \
          --replace-fail "megapixels" "megapixels-next" \
          --replace-fail "Name=Megapixels" "Name=Megapixels-Next"
      '';
    });

    # this sandboxing was derived from original megapixels: possibly inaccurate
    sandbox.wrapperType = "inplace";  #< for share/megapixels/movie.sh
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus = [ "user" ];  #< so that it can in theory open the image viewer using fdo portal... but it doesn't :|
    sandbox.extraHomePaths = [
      # ".config/megapixels"
      ".cache/mesa_shader_cache"  # loads way faster
      "Pictures/Photos"
      # also it addresses a lot via relative path.
    ];
    sandbox.extraPaths = [
      # it passes the raw .dng files to a post-processor, via /tmp
      "/tmp"
      "/sys/class/leds"  #< for flash, presumably
    ];
    sandbox.whitelistAvDev = true;
    gsettingsPersist = [
      # pretty sure one of these is the new directory, one the old, not sure which
      "me/gapixels/megapixels"  #< needs to set `postprocessor` else it will segfault during post-process
      "org/postmarketos/megapixels"
    ];

    env.CAMERA = "me.gapixels.Megapixels.desktop";
  };
}

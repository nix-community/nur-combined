# config is loaded from the first one found:
# - $PWD/config/%model.conf
# - /etc/megapixels/config/%model.conf  (SYSCONFDIR)
# - /usr/share/megapixels/config/%model.conf  (DATADIR -- maybe this is the package's own directory?)
# debug with:
# - LIBMEGAPIXELS_DEBUG=2 megapixels
#   2 = log level debug. no higher values signify anything
{ lib, pkgs, ... }:
{
  sane.programs.megapixels = {
    packageUnwrapped = pkgs.megapixels.overrideAttrs (upstream: {
      postPatch = (upstream.postPatch or "") + ''
        # 2024/04/21: patch it to save photos in a more specific directory
        substituteInPlace src/process_pipeline.c \
          --replace-fail 'XDG_PICTURES_DIR' 'XDG_PHOTOS_DIR'
        # 2024/04/21: patch it so the folder button works
        substituteInPlace src/main.c \
          --replace-fail 'g_get_user_special_dir(G_USER_DIRECTORY_PICTURES)' 'getenv("XDG_PHOTOS_DIR")'
      '';
    });
    # /share/megapixels/movie.sh refers to /libexec/megapixels, by path
    sandbox.wrapperType = "inplace";

    # megapixels sandboxing is tough:
    # if misconfigured, preview will alternately be OK, black, or only 1/4 of it will be rendered -- with no obvious pattern.
    # adding all of ~ to the sandbox will sometimes (?) fix the flakiness, even when `strace` doesn't show it accessing any files...
    # it might just be that megapixels is sensitive to low perf. e.g. it's racy
    #
    # further, it doesn't use either portals or xdg-open to launch the image viewer.
    # bwrap (loupe image viewer) doesn't like to run inside landlock
    #   "bwrap: failed to make / slave: Operation not permitted"
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  #< so that it can in theory open the image viewer using fdo portal... but it doesn't :|
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
    gsettingsPersist = [
      "org/postmarketos/megapixels"  #< needs to set `postprocessor` else it will segfault during post-process
    ];
    # source code references /proc/device-tree/compatible, but it seems to be alright either way
    # sandbox.keepPidsAndProc = true;

    mime.priority = 200;  #< fallback; prefer `megapixels-next` if it's installed
    env.CAMERA = lib.mkDefault "org.postmarketos.Megapixels.desktop";
  };
}

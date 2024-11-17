{ config, lib, ... }:
let
  cfg = config.sane.programs.libcamera;
in
{
  sane.programs.libcamera = {
    sandbox.method = null;  #< TODO: sandbox
  };
  services.udev.extraRules = lib.mkIf cfg.enabled ''
    # libcamera (snapshot, millipixels, ...)
    # see: <https://gitlab.com/postmarketOS/pmaports/-/merge_requests/5541>
    # can be removed for systemd 257+
    # - <https://github.com/systemd/systemd/pull/33738>
    #
    # i do the old and/or lazy way, just grant broad R+W access
    # dma_heap is the old resource; udmabuf is the new one.
    KERNEL=="udmabuf", GROUP="video", MODE="0660"
    SUBSYSTEM=="dma_heap", GROUP="video", MODE="0660"
  '';
}

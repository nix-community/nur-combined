{ ... }:
{
  imports = [
    ./remote-home.nix
    ./remote-servo.nix
  ];
  # some services which use private directories error if the parent (/var/lib/private) isn't 700.
  sane.fs."/var/lib/private".dir.acl.mode = "0700";


  # allocate a proper /tmp fs, else its capacity will be limited as per impermanence defaults (i.e. 1 GB).
  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "mode=777"
      "defaults"
    ];
  };

  # in-memory compressed RAM
  # defaults to compressing at most 50% size of RAM
  # claimed compression ratio is about 2:1
  # - but on moby w/ zstd default i see 4-7:1  (ratio lowers as it fills)
  # note that idle overhead is about 0.05% of capacity (e.g. 2B per 4kB page)
  # docs: <https://www.kernel.org/doc/Documentation/blockdev/zram.txt>
  #
  # to query effectiveness:
  # `cat /sys/block/zram0/mm_stat`. whitespace separated fields:
  # - *orig_data_size*  (bytes)
  # - *compr_data_size* (bytes)
  # - mem_used_total    (bytes)
  # - mem_limit         (bytes)
  # - mem_used_max      (bytes)
  # - *same_pages*  (pages which are e.g. all zeros (consumes no additional mem))
  # - *pages_compacted*  (pages which have been freed thanks to compression)
  # - huge_pages  (incompressible)
  #
  # see also:
  # - `man zramctl`
  zramSwap.enable = true;
  # how much ram can be swapped into the zram device.
  # this shouldn't be higher than the observed compression ratio.
  # the default is 50% (why?)
  # 100% should be "guaranteed" safe so long as the data is even *slightly* compressible.
  # but it decreases working memory under the heaviest of loads by however much space the compressed memory occupies (e.g. 50% if 2:1; 25% if 4:1)
  zramSwap.memoryPercent = 100;

  programs.fuse.userAllowOther = true;  #< necessary for `allow_other` or `allow_root` options.
}


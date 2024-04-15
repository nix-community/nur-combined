{lib, ...}: {
  options = {
    scripts.output = lib.mkOption {
      type = lib.types.lines;
    };
  };

  config.scripts.output = ''
    ./map size=640x640 scale=2 | feh -
  '';
}

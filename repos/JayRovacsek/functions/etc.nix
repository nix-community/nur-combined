{ config, ... }: { "${config.name}" = { inherit (config) text uid gid mode; }; }

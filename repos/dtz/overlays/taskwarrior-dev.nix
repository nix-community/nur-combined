# Use at your own risk!
# Make backups!
self: super: {
  taskwarrior = super.taskwarrior.overrideAttrs (o: rec {
    name = "taskwarrior-${version}";
    version = "2018-08-12"; # latest on 2.6.0 branch
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "taskwarrior";
      rev = "bd221a5adc43e5c70e05eb4f7a48d1db3d18555d";
      sha256 = "0jbh273rkw4j2hxln65f3cna5mnqfs642hsqcfvm7cqj77cz7gva";
      fetchSubmodules = true;
    };
    patches = [];
  });
}

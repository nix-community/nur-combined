# Use at your own risk!
# Make backups!
self: super: {
  taskwarrior = super.taskwarrior.overrideAttrs (o: rec {
    name = "taskwarrior-${version}";
    version = "2019-03-03"; # 2.5.2 branch
    src = super.fetchFromGitHub {
      owner = "GothenburgBitFactory";
      repo = "taskwarrior";
      rev = "b87703eb39e4ad89ef8f8447440d890d555678f6";
      sha256 = "10bz87p4q1jrf8k3vz0sjs7slakl6zfa4bjzk1g72y528sqhrxnp";
      fetchSubmodules = true;
    };
    patches = [];
  });
}

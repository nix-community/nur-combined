{ name, system, bootstrapFiles }:

derivation {
  inherit name;

  builder = bootstrapFiles.busybox;

  args = [ "ash" "-e" ./unpack-script.sh ];

  tarball = bootstrapFiles.tarball;

  inherit system;

  preferLocalBuild = true;
}

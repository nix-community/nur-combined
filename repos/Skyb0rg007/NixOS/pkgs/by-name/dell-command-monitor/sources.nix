# The three .deb packages that make up Dell Command | Monitor, shipped together
# in a single tarball that has to be downloaded by hand from Dell's website.
#
# Upstream install order (from the Ubuntu install instructions):
#   1. dpkg -i omi-<version>.ssl_<ssl>.ulinux.s.x64.deb
#   2. dpkg -i srvadmin-hapi_<version>_amd64.deb
#   3. dpkg -i command-monitor_<version>.ubuntu24_amd64.deb
{
  requireFile,
  runCommand,
}:
let
  version = "10.13.0-26";

  tarball = requireFile {
    name = "command-monitor_${version}.ubuntu24_amd64.tar.gz";
    url = "https://www.dell.com/support/kbdoc/en-us/000177080/dell-command-monitor";
    # nix hash convert --from base16 --to sri --hash-algo sha256 <hash-from-site>
    hash = "sha256-Ee6Hh/UEaBBuwjDwHHoApo5kps4ORXMHxa2GgSkltYA=";
  };
in
runCommand "dell-command-monitor-sources-${version}"
  {
    passthru = {
      inherit version tarball;
    };
  }
  ''
    mkdir -p $out
    tar -xzf ${tarball} -C $out
  ''

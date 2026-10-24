{ lib }:
{
  homepage = "https://cutefish.org/";
  platforms = lib.platforms.linux;
  version = date: "1.0-unstable-${date}";
  # Upstream installs to /usr and a few absolute destinations. The prefix is the
  # store path; SYSCONFDIR must not stay the GNU default of /etc.
  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_LIBEXECDIR=libexec"
    "-DCMAKE_INSTALL_SYSCONFDIR=${placeholder "out"}/etc"
  ];
}

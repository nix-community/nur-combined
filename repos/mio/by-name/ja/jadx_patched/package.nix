{
  jadx,
  lib,
  stdenv,
}:

jadx.overrideAttrs (
  old:
  lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Gradle runs the build in a single-use daemon that the client connects to
    # over TCP on localhost. The nix darwin sandbox only allows the IPv4
    # loopback (see ghidra in nixpkgs), and the JVM prefers ::1, which ends in
    # "Could not connect to the Gradle daemon: Operation not permitted".
    env = (old.env or { }) // {
      JAVA_TOOL_OPTIONS = "-Djava.net.preferIPv4Stack=true";
    };
  }
)

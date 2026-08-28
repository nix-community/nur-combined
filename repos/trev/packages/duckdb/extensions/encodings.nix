{ callPackage }:

(callPackage ./generic.nix { }) {
  name = "encodings";
  repo = "duckdb-encodings";
  branch = "main";
  rev = "f3e4d03ecf18406ef86fe5833a7ad55d8f93520f";
  hash = "sha256-U2BNceWrjnP85KYZ9OA97Xly46pSeokwUB/8y4XA60k=";
  loadOptions = [ "DONT_LINK" ];
}

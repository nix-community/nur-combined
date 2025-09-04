{
  apktool,
  bash,
  fetchFromGitHub,
  jadx,
  writeShellApplication,
}:
let
  src = fetchFromGitHub {
    owner = "n0mi1k";
    repo = "apk2url";
    rev = "d0ee6424797729233810c522e47c4a439e357491";
    sha256 = "sha256-OSuLwaCBckPoyQIyQzcjAlw2HM7NU49EhMi5PoHWWKM=";
  };
in
writeShellApplication {
  name = "apk2url";
  runtimeInputs = [
    apktool
    bash
    jadx
  ];
  text = "bash ${src}/apk2url.sh \"$@\"";
  derivationArgs = {
    version = "unstable-2024-02-24";
    preferLocalBuild = true;
  };
  meta = {
    description = "An OSINT tool to quickly extract IP and URL endpoints from APKs by disassembling and decompiling";
    homepage = "https://github.com/n0mi1k/apk2url";
  };
}

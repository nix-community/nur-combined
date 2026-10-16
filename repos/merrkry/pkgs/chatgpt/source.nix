{ fetchurl }:

rec {
  version = "26.1013.31256";
  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
    hash = "sha256-cMzyub94CY57u/3b8e4Zao/dQr63538W3UL6ujZAMyQ=";
  };

  componentHashes = {
    cua_node = "sha256-ReLN191h3RHdS/km72M5GlJkCVUjcToSbYlfxWVDfnM=";
    tectonic = "sha256-YjVgWEEjprm3gYq2/r22M9hCJNJAwqq+J2LNptUkdBI=";
  };
}

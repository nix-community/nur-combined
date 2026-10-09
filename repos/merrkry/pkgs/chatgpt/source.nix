{ fetchurl }:

rec {
  version = "26.1007.21434";
  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
    hash = "sha256-J2tTQcPXSyYdOtUhBvf6ft3gaEHkdn/ipAy1QJmx8+0=";
  };

  componentHashes = {
    cua_node = "sha256-4vm6HucJ0el9rE1PEpggy7oQhux72bXcrD6SJisvskI=";
    tectonic = "sha256-YjVgWEEjprm3gYq2/r22M9hCJNJAwqq+J2LNptUkdBI=";
  };
}

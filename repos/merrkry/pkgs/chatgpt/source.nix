{ fetchurl }:

rec {
  version = "26.1002.51308";
  src = fetchurl {
    url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/pool/main/c/chatgpt/chatgpt_${version}_amd64.deb";
    hash = "sha256-zlmmG5Te9JzJIdaU75Uh7BdOuLZf2wwoXjuo5FIxoh8=";
  };

  componentHashes = {
    cua_node = "sha256-Y+xw0Gf8h2XI43v1s0Pj+6MFdqXnypBhL8++EJ22dHs=";
    tectonic = "sha256-YjVgWEEjprm3gYq2/r22M9hCJNJAwqq+J2LNptUkdBI=";
  };
}

{ openssl, telethon, python3Packages, mylibs }:
with python3Packages;
buildPythonApplication rec {
  format = "other";
  pname = "telegramircd";
  version = "master";
  propagatedBuildInputs = [ telethon aiohttp ConfigArgParse openssl ];
  src = (mylibs.fetchedGithub ./telegramircd.json).src;
  LD_LIBRARY_PATH = "${openssl.out}/lib";
  installPhase = ''
    install -D $src/telegramircd.py $out/bin/telegramircd
    wrapProgram "$out/bin/telegramircd" \
      --prefix LD_LIBRARY_PATH : "${openssl.out}/lib"
    install -Dm644 "$src/config" -t "$out/etc/telegramircd/"
    '';
}

{ sources, lib, python3Packages, stdenv }:

python3Packages.buildPythonApplication rec {
  inherit (sources.telegram-send) pname version src;

  propagatedBuildInputs = with python3Packages; [
    python-telegram-bot
    colorama
    appdirs
  ];

  patches = [
    # TODO https://github.com/rahiel/telegram-send/pull/117
    ./fix-max-text-length.patch
  ];

  meta = with lib; {
    homepage = "https://github.com/rahiel/telegram-send";
    description = "Send messages and files over Telegram from the command-line";
    license = licenses.mit;
    # TODO https://github.com/pyca/pyopenssl/issues/873
    # TODO https://github.com/NixOS/nixpkgs/pull/201299
    broken = python3Packages.pyopenssl.meta.broken ||
      python3Packages.pymemcache.meta.broken ||
      !(versionAtLeast (versions.majorMinor trivial.version) "23.05");
    maintainers = with maintainers; [ yinfeng ];
  };
}

{ pkgs, ... }:
{
  sane.programs.python3-repl = {
    sandbox.wrapperType = "inplace";  #< else importing from site-packages fails
    packageUnwrapped = pkgs.python3.withPackages (ps: with ps; [
      libgpiod
      numpy
      psutil
      pydantic
      pykakasi
      requests
      scipy
      unidecode
    ]);
    sandbox.net = "clearnet";
    sandbox.autodetectCliPaths = "existing";  #< for invoking scripts like `python3 ./my-script.py`
    sandbox.whitelistPwd = true;  #< way more convenient
    sandbox.extraPaths = [
      "/tmp"  #< mostly just for pi-coding-agent... i can maybe find something better someday
    ];
    # sandbox.extraHomePaths = [
    #   "/"  #< this is 'safe' because we don't expose .persist/private, so no .ssh/id_ed25519
    #   ".persist/plaintext"
    # ];

    persist.byStore.plaintext = [ ".local/state/python" ];

    env.PYTHON_HISTORY = "$XDG_STATE_HOME/python/history";
  };
}

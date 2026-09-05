let
  mkSystemctlCmds = prefix: base:
    let
      list = sub: base ++ [ "list-${sub}" ];
      listJson = sub: list sub ++ [ "--output=json" ];
    in
    {
      "${prefix}" = base;
      "${prefix}c" = base ++ [ "cat" ];
      "${prefix}s" = base ++ [ "status" ];
      "${prefix}w" =
        [ "watch" "--color" "SYSTEMD_URLIFY=0" "SYSTEMD_COLORS=1" ] ++ base ++ [ "status" ];
      "${prefix}a" = base ++ [ "start" ];
      "${prefix}o" = base ++ [ "stop" ];
      "${prefix}r" = base ++ [ "restart" ];
      "${prefix}lt" = list "timers";
      "${prefix}ls" = list "sockets";
      "${prefix}lm" = list "machines";
      "${prefix}lu" = list "units";
      "${prefix}lf" = list "unit-files";
      "${prefix}ltj" = listJson "timers";
      "${prefix}lsj" = listJson "sockets";
      "${prefix}lmj" = listJson "machines";
      "${prefix}luj" = listJson "units";
      "${prefix}lfj" = listJson "unit-files";
    };
in

{

  imports = [ ./shortcommands.nix ];

  nagy.shortcommands.commands = {

  } // mkSystemctlCmds "sc" [ "systemctl" ] // mkSystemctlCmds "scU" [ "systemctl" "--user" ] // {
    juf = [ "journalctl" "--follow" ];
    jufu = [ "journalctl" "--follow" "--unit" ];
    juUf = [ "journalctl" "--user" "--follow" ];
    juUfu = [ "journalctl" "--user" "--follow" "--unit" ];
    j = [ "jq" "--monochrome-output" ];
    jr = [ "jq" "--monochrome-output" "--raw-output" ];
    js = [ "jq" "--monochrome-output" "--slurp" ];
    jl = [ "jq" "--monochrome-output" "length" ];
    jcP = [ "jc" "--pretty" ];
    y = [ "yq" "--prettyPrint" "--no-colors" ];
    yj = [ "yq" "--prettyPrint" "--no-colors" "--output-format" "json" ];
    cpa = [ "cp" "--archive" ];
    i4 = [ "ip" "-4" ];
    i6 = [ "ip" "-6" ];
    ij = [ "ip" "--json" ];
    i4j = [ "ip" "-4" "--json" ];
    i6j = [ "ip" "-6" "--json" ];
    ipa = [ "ip" "address" ];
    ipl = [ "ip" "link" ];
    ipr = [ "ip" "route" ];
    ipn = [ "ip" "neighbour" ];
    i4a = [ "ip" "-4" "address" ];
    i4l = [ "ip" "-4" "link" ];
    i4r = [ "ip" "-4" "route" ];
    i4n = [ "ip" "-4" "neighbour" ];
    i6a = [ "ip" "-6" "address" ];
    i6l = [ "ip" "-6" "link" ];
    i6r = [ "ip" "-6" "route" ];
    i6n = [ "ip" "-6" "neighbour" ];
    sha1 = [ "sha1sum" ];
    sha256 = [ "sha256sum" ];
    sha2 = [ "sha256sum" ];
    sha512 = [ "sha512sum" ];
    sha5 = [ "sha512sum" ];
    wcc = [ "wc" "-c" ];
    wcl = [ "wc" "-l" ];
    e64 = [ "base64" ];
    d64 = [ "base64" "--decode" ];
  };
}

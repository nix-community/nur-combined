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
    # sqlite
    q = [ "sqlite3" ];
    qj = [ "sqlite3" "-json" ];
    qt = [ "sqlite3" "-table" ];
    qb = [ "sqlite3" "-box" ];
    qh = [ "sqlite3" "-html" ];
    qc = [ "sqlite3" "-csv" ];

  } // mkSystemctlCmds "sc" [ "systemctl" ] // mkSystemctlCmds "scU" [ "systemctl" "--user" ] // {
    juf = [ "journalctl" "--follow" ];
    jufu = [ "journalctl" "--follow" "--unit" ];
    juUf = [ "journalctl" "--user" "--follow" ];
    juUfu = [ "journalctl" "--user" "--follow" "--unit" ];

    # misc
    j = [ "jq" "--monochrome-output" ];
    jr = [ "jq" "--monochrome-output" "--raw-output" ];
    js = [ "jq" "--monochrome-output" "--slurp" ];
    jl = [ "jq" "--monochrome-output" "length" ];

    jcP = [ "jc" "--pretty" ];

    y = [ "yq" "--prettyPrint" "--no-colors" ];
    yj = [ "yq" "--prettyPrint" "--no-colors" "--output-format" "json" ];
    cpa = [ "cp" "--archive" ];
    rmf = [ "rm" "--force" ];
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
    hex = [ "hexdump" "--no-squeezing" "--canonical" ];
    hexn = [ "hexdump" "--no-squeezing" "--canonical" "--length" ];
    hexx = [ "hexyl" "--border" "none" ];
    sha1 = [ "sha1sum" ];
    sha256 = [ "sha256sum" ];
    sha2 = [ "sha256sum" ];
    sha512 = [ "sha512sum" ];
    sha5 = [ "sha512sum" ];
    grepi = [ "grep" "-i" ];
    wcc = [ "wc" "-c" ];
    wcl = [ "wc" "-l" ];
    dush = [ "du" "-sh" ];
    dfh = [ "df" "-h" ];
    dfhh = [ "df" "-h" "/home" ];
    # w1 = [ "watch" "--interval" "1" ];
    w05 = [ "watch" "--interval" "0.5" ];
    mask = [ "openssl" "env" "-e" "-aes-256-ctr" "-nopad" "-nosalt" "-k" "" ];
    numiec = [ "numfmt" "--to=iec" ];

    ungron = [ "gron" "--ungron" ];
    pingc3 = [ "ping" "-c" "3" ];
    e64 = [ "base64" ];
    d64 = [ "base64" "--decode" ];

    fd1 = [ "fd" "-j1" ];
    fd1f = [ "fd" "-j1" "-tf" ];
    fd1d = [ "fd" "-j1" "-td" ];
    fd2 = [ "fd" "-j2" ];
    fd2f = [ "fd" "-j2" "-tf" ];
    fd2d = [ "fd" "-j2" "-td" ];
    fdf = [ "fd" "-tf" ];
    fdd = [ "fd" "-td" ];
  };
}

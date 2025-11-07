{
  nagy.shortcommands.commands = {
    # sqlite
    q = [ "sqlite3" ];
    qj = [ "sqlite3" "-json" ];
    qt = [ "sqlite3" "-table" ];
    qb = [ "sqlite3" "-box" ];
    qh = [ "sqlite3" "-html" ];
    qc = [ "sqlite3" "-csv" ];

    # systemctl
    sc = [ "systemctl" ];
    scc = [ "systemctl" "cat" ];
    scs = [ "systemctl" "status" ];
    scw = [ "watch" "--color" "SYSTEMD_COLORS=1" "systemctl" "status" ];
    sca = [ "systemctl" "start" ];
    sco = [ "systemctl" "stop" ];
    scr = [ "systemctl" "restart" ];
    sclt = [ "systemctl" "list-timers" ];
    scls = [ "systemctl" "list-sockets" ];
    sclm = [ "systemctl" "list-machines" ];
    sclu = [ "systemctl" "list-units" ];
    sclf = [ "systemctl" "list-unit-files" ];
    scltj = [ "systemctl" "list-timers" "--output=json" ];
    sclsj = [ "systemctl" "list-sockets" "--output=json" ];
    sclmj = [ "systemctl" "list-machines" "--output=json" ];
    scluj = [ "systemctl" "list-units" "--output=json" ];
    sclfj = [ "systemctl" "list-unit-files" "--output=json" ];
    scU = [ "systemctl" "--user" ];
    scUc = [ "systemctl" "--user" "cat" ];
    scUs = [ "systemctl" "--user" "status" ];
    scUw = [ "watch" "--color" "SYSTEMD_COLORS=1" "systemctl" "--user" "status" ];
    scUa = [ "systemctl" "--user" "start" ];
    scUo = [ "systemctl" "--user" "stop" ];
    scUr = [ "systemctl" "--user" "restart" ];
    scUlt = [ "systemctl" "--user" "list-timers" ];
    scUls = [ "systemctl" "--user" "list-sockets" ];
    scUlm = [ "systemctl" "--user" "list-machines" ];
    scUlu = [ "systemctl" "--user" "list-units" ];
    scUlf = [ "systemctl" "--user" "list-unit-files" ];
    scUltj = [ "systemctl" "--user" "list-timers" "--output=json" ];
    scUlsj = [ "systemctl" "--user" "list-sockets" "--output=json" ];
    scUlmj = [ "systemctl" "--user" "list-machines" "--output=json" ];
    scUluj = [ "systemctl" "--user" "list-units" "--output=json" ];
    scUlfj = [ "systemctl" "--user" "list-unit-files" "--output=json" ];
    juf = [ "journalctl" "-f" ];

    # misc
    j = [ "jq" "--monochrome-output" "--sort-keys" ];
    jr = [ "jq" "--monochrome-output" "--sort-keys" "--raw-output" ];
    js = [ "jq" "--monochrome-output" "--slurp" ];
    jl = [ "jq" "--monochrome-output" "length" ];

    jcP = [ "jc" "--pretty" ];

    y = [ "yq" "--prettyPrint" "--no-colors" ];
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

from i3pystatus import Status

status = Status()

status.register("clock", format="%X")
status.register(
    "battery",
    format="%{percentage_design:.1f}{status} {remaining}",
    status=dict(DPL="DPL", CHR="+", DIS="-", FULL="!"),
)
status.register("tlp")

status.register(
    "mem", format="{percent_used_mem}", warn_percentage=80, alert_percentage=90
)

status.register(
    "cpu_usage",
    format="{usage}",
    format_all="C",
    exclude_average=True,
    dynamic_color=True,
)

status.register(
    "disk",
    format="/ {avail}GB free!",
    color="#FF0000",
    # format='/={percentage_used}%',
    path="/",
    display_limit=100.0,
)

status.register(
    "keyboard_locks",
    format="{caps}{num}{scroll}",
    caps_on="C",
    caps_off="c",
    num_on="N",
    num_off="n",
    scroll_on="S",
    scroll_off="s",
)

status.register("load", format="{tasks}")

status.register(
    "network",
    format_up="{interface} {bytes_sent}/{bytes_recv}",
    format_down="",
    detect_active=True,
    auto_units=True,
)

status.register("temp")

status.run()

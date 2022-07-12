function dock2
    xrandr \
        --output eDP-1 --mode 1920x1080 --pos 2560x0 --rotate normal \
        --output DP-1 --primary --mode 2560x1440 --pos 0x0 --rotate normal \
        --output HDMI-1 --off \
        --output DP-2 --off \
        --output HDMI-2 --off

    i3-msg -q '[workspace="1"]' move workspace to output DP-1 2>/dev/null
    i3-msg -q '[workspace="2"]' move workspace to output DP-1 2>/dev/null
    i3-msg -q '[workspace="3"]' move workspace to output DP-1 2>/dev/null
    i3-msg -q '[workspace="4"]' move workspace to output DP-1 2>/dev/null
    i3-msg -q '[workspace="9"]' move workspace to output DP-1 2>/dev/null

    i3-msg -q '[workspace="10"]' move workspace to output eDP-1 2>/dev/null
end

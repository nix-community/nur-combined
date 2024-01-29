function dock
    xrandr \
        --output eDP-1 --mode 1920x1080 --pos 0x120 --rotate normal \
        --output HDMI-1 --off \
        --output DP-1 --off \
        --output DP-2 --off \
        --output DP-3 --primary --mode 1920x1200 --pos 1920x0 --rotate normal \
        --output DP-4 --mode 1920x1200 --pos 3840x0 --rotate normal \
        --output DP-4 --off \
        --output DP-5 --off

    i3-msg -q '[workspace="1"]' move workspace to output DP-3 2>/dev/null
    i3-msg -q '[workspace="2"]' move workspace to output DP-3 2>/dev/null
    i3-msg -q '[workspace="3"]' move workspace to output DP-3 2>/dev/null
    i3-msg -q '[workspace="4"]' move workspace to output DP-3 2>/dev/null
    i3-msg -q '[workspace="5"]' move workspace to output DP-3 2>/dev/null

    i3-msg -q '[workspace="7"]' move workspace to output eDP-1 2>/dev/null

    i3-msg -q '[workspace="8"]' move workspace to output DP-4 2>/dev/null
    i3-msg -q '[workspace="9"]' move workspace to output DP-4 2>/dev/null
    i3-msg -q '[workspace="10"]' move workspace to output DP-4 2>/dev/null
end

function undock2
    xrandr \
        --output eDP-1 --primary --mode 1920x1080 --rotate normal \
        --output DP-1 --off \
        --output HDMI-1 --off \
        --output DP-2 --off \
        --output HDMI-2 --off
end

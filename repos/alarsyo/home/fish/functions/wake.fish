function wake -d "Wake-on-WiFi shortcut" -a host
    if not set -q host[1]
        echo "Usage: wake HOSTNAME"
        return 1
    end

    switch $host
        case boreal
            ssh -t pi@pi.alarsyo.net "bash -ic wakywaky"
        case *
            echo "Unknown host!"
            return 1
    end
end

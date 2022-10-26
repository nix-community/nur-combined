local gears = require("gears")

function scandir(directory, filter)
    local i, t, popen = 0, {}, io.popen
    if not filter then
        filter = function(s) return true end
    end
    print(filter)
    for filename in popen('ls -a "'..directory..'"'):lines() do
        if filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    return t
end

wp_index = 1
wp_timeout  = 100
wp_path = "/home/pim/Pictures/wallpapers/"
wp_filter = function(s) return string.match(s:lower(),"%.png$") or string.match(s:lower(),"%.jpg$") end
wp_files = scandir(wp_path, wp_filter)

gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, false)
wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal( "timeout", function()
    for s = 1, screen.count() do
      gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, false)
    end

    wp_timer:stop()

    wp_index = math.random( 1, #wp_files)

    wp_timer.timeout = wp_timeout
    wp_timer:start()
  end
)

wp_timer:start()

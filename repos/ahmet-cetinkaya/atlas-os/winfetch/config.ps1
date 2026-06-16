# ===== WINFETCH CONFIGURATION =====

# $image = "~/winfetch.png"
# $noimage = $true

# Display image using ASCII characters
# $ascii = $true

# Set the version of Windows to derive the logo from.
# $logo = "Windows 10"

# Specify width for image/logo
# $imgwidth = 24

# Specify minimum alpha value for image pixels to be visible
# $alphathreshold = 50

# Custom ASCII Art
# This should be an array of strings, with positive
# height and width equal to $imgwidth defined above.
$customascii = @(
	"                                   "
	"                                   "
	"                 @                 "           
	"                @@@(               "           
	"              .@@@@@               "           
	"             @@@@@@@@@             "           
	"            @@@@@@@@@@@            "           
	"          *@@@@@@ @@@@@@           "           
	"         @@@@@@/   @@@@@@@         "           
	"        @@@@@@/     (@@@@@@        "           
	"                      @@@@@@       "           
	"                       @@@@@@      "           
	"    @@@@@@@@@@@@@@@@@@@@@@@@@@     "           
	"   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@   "
	" *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@/ "
)

# Make the logo blink
# $blink = $true

# Display all built-in info segments.
# $all = $true

# Add a custom info line
# function info_custom_time {
#     return @{
#         title = "Time"
#         content = (Get-Date)
#     }
# }
function info_atlas_os_name {
    return @{
        title = "OS"
		content = "AtlasOS v0.4 [64-bit]"
    }
}

# Configure which disks are shown
# $ShowDisks = @("C:", "D:")
# Show all available disks
# $ShowDisks = @("*")

# Configure which package managers are shown
# disabling unused ones will improve speed
# $ShowPkgs = @("winget", "scoop")

# Use the following option to specify custom package managers.
# Create a function with that name as suffix, and which returns
# the number of packages. Two examples are shown here:
# $CustomPkgs = @("cargo", "just-install")
# function info_pkg_cargo {
#     return (cargo install --list | Where-Object {$_ -like "*:" }).Length
# }
# function info_pkg_just-install {
#     return (just-install list).Length
# }

# Configure how to show info for levels
# Default is for text only.
# 'bar' is for bar only.
# 'textbar' is for text + bar.
# 'bartext' is for bar + text.
# $cpustyle = 'bar'
# $memorystyle = 'textbar'
# $diskstyle = 'bartext'
# $batterystyle = 'bartext'


# Remove the '#' from any of the lines in
# the following to **enable** their output.

@(
    "title"
    "dashes"
    "atlas_os_name"
    "computer"
    "kernel"
    "motherboard"
    # "custom_time"  # use custom info line
    "uptime"
    # "ps_pkgs"  # takes some time
    # "pkgs"
    "pwsh"
    "resolution"
    "terminal"
    # "theme"
    "cpu"
    "gpu"
    # "cpu_usage"
    "memory"
    "disk"
    # "battery"
    # "locale"
    # "weather"
    # "local_ip"
    # "public_ip"
    "blank"
    "colorbar"
)

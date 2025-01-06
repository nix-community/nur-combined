# satellite-gtk: <https://codeberg.org/tpikonen/satellite>
# - presents GPS tracking *details* in a graphical way
#   - shows which satellites are in view, their SNR, and the subset currently being used for triangulation
#   - shows fix coordinates (time, lat, long, altitude, speed)
#
### how to read the bargraph (example):
#
# 14 | XXXXXXXXXXXXX 26
# 76 | =========== 23
# 15 | XXXXXXXX 16
#    =
#    +----------------|
#    0               30
#
# ^ this view means:
# - GPS is receiving from sats 14, 76, 15 (by PRN)  -- this comes from GSGSV NMEA data (Satellites in-View)
# - sat 14 and 15 (shaded solid) are "active"  -- this comes from GSGSA NMEA data ("Satellites Active")
#   - i believe "active" means "this sat was used in the most recent solution"
#
### text fields
# - Modes (GP,GL,GA) ...
#   one letter each, indicating the mode for GPS, GLONASS, Galileo sats:
#   - N = no fix
#   - A = autonomous
#   - D = differential mode
#   - E = estimated (dead reckoning)
#   - etc
# - Active / in use sats
#   - A/U, where A = number of satellites used in the previous fix,
#                U = number of satellites mentioned in latest GNS + GGA messages
# - Receiving sats
#   shows the count of sats with non-zero SNR, from GSV messages
# - Visible sats
#   shows the count of sats from GSV messages
# - Age of update / fix
# - Sys. Time
# - Latitude
# - Longitude
# - Altitude
# - Geoidal separation
# - Speed
# - True Course
# - PDOP/HDOP/VDOP
#   - shows how sensitive the reported location is to measurement error (low values are better)
#     - HDOP = horizontal sensitivity, VDOP = vertical sensitivity, PDOP = positional (d) sensitivity
#     - 1-2  => excellent fix
#     - >10  => low confidence fix; recommended to discard the fix
#   - <https://en.wikipedia.org/wiki/Dilution_of_precision_(navigation)>
#
{ ... }:
{
  sane.programs.satellite = {
    sandbox.whitelistDbus.system = true;  #< reads NMEA data via ModemManager
    sandbox.whitelistWayland = true;
    sandbox.mesaCacheDir = ".cache/satellite/mesa";  # TODO: is this the correct app-id?
  };
}

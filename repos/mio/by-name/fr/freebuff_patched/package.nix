# Freebuff with the ad creatives hidden from the screen.
#
# The ad pipeline itself is untouched: the auction still runs, the served ads
# are still recorded as impressions and engagement, and the click path is
# unchanged. Only the drawing of the creatives is dropped, so the server sees
# the same "ad shown" evidence it sees for the unpatched CLI. Hidden surfaces:
#
#   - the rotating dock card and its expandable panel (AdCard, DockAdCard,
#     DockDetailPanel), which also covers inline transcript ads and the
#     landing-screen columns;
#   - the composer partner row (PartnerAdLineView);
#   - the launch splash and footer statusline display ads.
#
# `/deals` is a command the user runs on purpose, so its list still prints.
# Sponsored *proposals* (the opt-in sponsored task cards) are not display ads
# and are left alone.
{ freebuff }:

freebuff.overrideAttrs (old: {
  pname = "freebuff-patched";

  patches = (old.patches or [ ]) ++ [ ./patches/hide-ads.patch ];

  meta = (old.meta or { }) // {
    description = "Free AI coding agent CLI (Freebuff) without on-screen ad creatives";
  };
})

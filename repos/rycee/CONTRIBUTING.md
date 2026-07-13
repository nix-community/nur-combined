# Contributing

If you want to add a Firefox or Thunderbord addon then there are two
alternatives:

1. If the addon is present on the official
   [Firefox](https://addons.mozilla.org/en-US/firefox/) or
   [Thunderbird](https://addons.thunderbird.net/) addon sites then
   simply create an issue with links to the addon on those pages. For
   example,

   - https://addons.mozilla.org/en-US/firefox/addon/cookie-autodelete/
   - https://addons.thunderbird.net/en-US/thunderbird/addon/send-later-3/

   There is no need to create a merge request. If you prefer
   Sourcehut, then you can create a ticket at
   <https://todo.sr.ht/~rycee/nur-expressions>.

1. If the addon is not present on the official addon sites then please
   create a merge request that includes a package for the addon, use
   the existing packages in [`pkgs/firefox-addons/default.nix`][] and
   [`pkgs/thunderbird-addons/default.nix`][] as models. Please note
   that you will be expected to maintain these packages, if you want
   you can add an update script that will be run daily.

[`pkgs/firefox-addons/default.nix`]: https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/firefox-addons/default.nix?ref_type=heads
[`pkgs/thunderbird-addons/default.nix`]: https://gitlab.com/rycee/nur-expressions/-/blob/master/pkgs/thunderbird-addons/default.nix?ref_type=heads

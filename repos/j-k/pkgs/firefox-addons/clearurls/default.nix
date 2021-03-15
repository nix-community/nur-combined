{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "clearurls";
  url = "https://addons.mozilla.org/firefox/downloads/file/3682334/clearurls-1.20.0-an+fx.xpi";
  sha256 = "sha256-LUvdbHApmfLXbJfL1qC7gMve9GZcPBBLOIJOncBhbfI=";

  # meta = with lib; {
  #   homepage = "https://clearurls.xyz/";
  #   changelog = "https://gitlab.com/KevinRoebert/ClearUrls/-/blob/master/CHANGELOG.md";
  #   description = "An addon that removes tracking elements from URLs";
  #   longDescription = ''
  #     This extension will automatically remove tracking elements from URLs to
  #     help protect your privacy when browse through the Internet.

  #     Many websites use tracking elements in the URL to mark your online
  #     activity. All that tracking code is not necessary for a website to be
  #     displayed or work correctly and can therefore be removed—that is exactly
  #     what ClearURLs does.
  #   '';
  #   license = licenses.lgpl3Plus;
  #   maintainers = with maintainers; [ jk ];
  # };
}

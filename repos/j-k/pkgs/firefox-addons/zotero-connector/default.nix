{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "zotero-connector";
  url = "https://download.zotero.org/connector/firefox/release/Zotero_Connector-5.0.84.xpi";
  sha256 = "sha256-96N43eOYiBYdFFeAJg+5Fd2NnQj0zrJ51nl9GXiRP8s=";

  # meta = with lib; {
  #   https://github.com/zotero/zotero-connectors/
  #   homepage = "https://www.zotero.org/download/connectors";
  #   description = "An addon for Zotero";
  #   license = licenses.agpl3;
  #   maintainers = with maintainers; [ jk ];
  # };
}

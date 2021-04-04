{ callPackage }:

{
  _1password-x = callPackage ./1password-x { };
  auto-tab-discard = callPackage ./auto-tab-discard { };
  clearurls = callPackage ./clearurls { };
  cors-everywhere = callPackage ./cors-everywhere { };
  decentraleyes = callPackage ./decentraleyes { };
  disable-webrtc = callPackage ./disable-webrtc { };
  https-everywhere = callPackage ./https-everywhere { };
  laboratory-csp-toolkit = callPackage ./laboratory-csp-toolkit { };
  noscript = callPackage ./noscript { };
  preact-devtools = callPackage ./preact-devtools { };
  react-devtools = callPackage ./react-devtools { };
  refined-github = callPackage ./refined-github { };
  stylus = callPackage ./stylus { };
  tree-style-tab = callPackage ./tree-style-tab { };
  ublock-origin = callPackage ./ublock-origin { };
  view-image = callPackage ./view-image { };
  zotero-connector = callPackage ./zotero-connector { };
}

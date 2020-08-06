{ callPackage, stdenv }:

let
  pfetch = {
    # Pick name from pattern "dwm-nameofpatch-versionorgithash"
    name ? builtins.elemAt (builtins.split "-" patchName) 2, patchName, sha256
    }:
    callPackage ({ fetchpatch }:
      fetchpatch {
        name = "${name}.patch";
        url = "https://dwm.suckless.org/patches/${name}/${patchName}.diff";
        inherit sha256;
      } // {
        meta = with stdenv.lib; {
          description = "A patch for dwm";
          longDescription = ''
            A patch for dwm.

            Full url: https://dwm.suckless.org/patches/${name}/${patchName}.diff
          '';
          homepage = "https://dwm.suckless.org/patches/${name}";
          # All patches should be licensed via MIT (I think) because dwm is
          # and the website says all contributions are licensed according to the license of the original project.
          license = licenses.mit;
          platforms = platforms.all;
        };
      }) { };
in {
  swallow = pfetch {
    patchName = "dwm-swallow-20200707-8d1e703";
    sha256 = "159xmcbprb9439gc6685crfddh660sy5d47b82bs77d6gjydik4x";
  };

  namedscratchpads = pfetch {
    patchName = "dwm-namedscratchpads-6.2";
    sha256 = "1h1akphlfv5sq60a703w0d05wwkq1yq1pa8970yp9hyymdm8p1h6";
  };

  keymodes = pfetch {
    patchName = "dwm-keymodes-5.8.2";
    sha256 = "1fmwys8pyqqdc00jxw874h17f51bl0bwbaw7vlnwn7dan3c3wndh";
  };

  floatrules = pfetch {
    patchName = "dwm-floatrules-6.2";
    sha256 = "0851c3hf6h3kr8x7lj28na3wl1p9wfqf5hl31qw67ibnhgll6y0x";
  };

  actualfullscreen = pfetch {
    patchName = "dwm-actualfullscreen-20191112-cb3f58a";
    sha256 = "05swkivarbcjkhhjd1l8kjgqh8dsqi0dr49xd2xayxinldh9ijj8";
  };

  cyclelayouts = pfetch {
    patchName = "dwm-cyclelayouts-20180524-6.2";
    sha256 = "1y87fgwfdgzycdbyqsmj737g89b2wf5illxpvp4pk4msn8i0w2l8";
  };

  anybar = pfetch {
    patchName = "dwm-anybar-20200721-bb2e722";
    sha256 = "15xccai630vzv7vpnzz4mlniyswn85wb65dmyjsq3xrdjfbb0rmj";
  };
}

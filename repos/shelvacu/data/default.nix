{ vaculib, ... }:
{
  _class = "vacuData";
  
  imports = vaculib.directoryGrabberList ./.;

  options.data.mtu = vaculib.mkOutOptions rec {
    t2dWanEth = 1500;
    t2dWanV4 = t2dWanEth - 8;
    t2dWavV6 = 1280;
    wgDoof = 
      # in theory it should be
      #   let
      #     ipv4Header = 20;
      #     udpHeader = 8;
      #     wireguardHeader = 32;
      #   in
      #   t2dWanV4 - ipv4Header - udpHeader - wireguardHeader;
      # but actually because the other side sets it to 1420 (wireguard default), I should as well
      1420;
  };
}

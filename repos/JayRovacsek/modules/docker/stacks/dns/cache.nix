let piholeUser = import ../../../../users/service-accounts/pihole.nix;
in {
  name = "pihole/dnsmasq.d/04-cache.conf";
  text = ''
    # Lancache Rebinds (https://github.com/uklans/cache-domains)

    # Blizzard
    address=/dist.blizzard.com/192.168.16.2
    address=/dist.blizzard.com.edgesuite.net/192.168.16.2
    address=/llnw.blizzard.com/192.168.16.2
    address=/edgecast.blizzard.com/192.168.16.2
    address=/blizzard.vo.llnwd.net/192.168.16.2
    address=/blzddist1-a.akamaihd.net/192.168.16.2
    address=/blzddist2-a.akamaihd.net/192.168.16.2
    address=/blzddist3-a.akamaihd.net/192.168.16.2
    address=/blzddist4-a.akamaihd.net/192.168.16.2
    address=/level3.blizzard.com/192.168.16.2
    address=/nydus.battle.net/192.168.16.2
    address=/edge.blizzard.top.comcast.net/192.168.16.2
    address=/cdn.blizzard.com/192.168.16.2
    address=/.cdn.blizzard.com/192.168.16.2

    # Epic
    address=/cdn1.epicgames.com/192.168.16.2
    address=/cdn.unrealengine.com/192.168.16.2
    address=/cdn1.unrealengine.com/192.168.16.2
    address=/cdn2.unrealengine.com/192.168.16.2
    address=/cdn3.unrealengine.com/192.168.16.2
    address=/download.epicgames.com/192.168.16.2
    address=/download2.epicgames.com/192.168.16.2
    address=/download3.epicgames.com/192.168.16.2
    address=/download4.epicgames.com/192.168.16.2
    address=/epicgames-download1.akamaized.net/192.168.16.2
    address=/fastly-download.epicgames.com/192.168.16.2

    # Nintendo
    address=/ccs.cdn.wup.shop.nintendo.com/192.168.16.2
    address=/ccs.cdn.wup.shop.nintendo.net/192.168.16.2
    address=/ccs.cdn.wup.shop.nintendo.net.edgesuite.net/192.168.16.2
    address=/geisha-wup.cdn.nintendo.net/192.168.16.2
    address=/geisha-wup.cdn.nintendo.net.edgekey.net/192.168.16.2
    address=/idbe-wup.cdn.nintendo.net/192.168.16.2
    address=/idbe-wup.cdn.nintendo.net.edgekey.net/192.168.16.2
    address=/ecs-lp1.hac.shop.nintendo.net/192.168.16.2
    address=/receive-lp1.dg.srv.nintendo.net/192.168.16.2
    address=/.wup.shop.nintendo.net/192.168.16.2
    address=/.wup.eshop.nintendo.net/192.168.16.2
    address=/.hac.lp1.d4c.nintendo.net/192.168.16.2
    address=/.hac.lp1.eshop.nintendo.net/192.168.16.2

    # Origin
    address=/origin-a.akamaihd.net/192.168.16.2
    address=/lvlt.cdn.ea.com/192.168.16.2
    address=/cdn-patch.swtor.com/192.168.16.2

    # Riot
    address=/l3cdn.riotgames.com/192.168.16.2
    address=/worldwide.l3cdn.riotgames.com/192.168.16.2
    address=/riotgamespatcher-a.akamaihd.net/192.168.16.2
    address=/riotgamespatcher-a.akamaihd.net.edgesuite.net/192.168.16.2
    address=/.dyn.riotcdn.net/192.168.16.2

    # Rockstar
    address=/patches.rockstargames.com/192.168.16.2

    # Sony
    address=/gs2.ww.prod.dl.playstation.net/192.168.16.2
    address=/gs2.sonycoment.loris-e.llnwd.net/192.168.16.2
    address=/pls.patch.station.sony.com/192.168.16.2
    address=/.gs2.ww.prod.dl.playstation.net/192.168.16.2
    address=/.gs2.sonycoment.loris-e.llnwd.net/192.168.16.2
    address=/gs2-ww-prod.psn.akadns.net/192.168.16.2
    address=/.gs2-ww-prod.psn.akadns.net/192.168.16.2
    address=/gs2.ww.prod.dl.playstation.net.edgesuite.net/192.168.16.2
    address=/.gs2.ww.prod.dl.playstation.net.edgesuite.net/192.168.16.2
    address=/playstation4.sony.akadns.net/192.168.16.2
    address=/theia.dl.playstation.net/192.168.16.2
    address=/tmdb.np.dl.playstation.net/192.168.16.2
    address=/gs-sec.ww.np.dl.playstation.net/192.168.16.2

    # Steam
    address=/lancache.steampowered.com/192.168.16.2
    address=/lancache.steamcontent.com/192.168.16.2
    address=/.content.steampowered.com/192.168.16.2
    address=/content1.steampowered.com/192.168.16.2
    address=/content2.steampowered.com/192.168.16.2
    address=/content3.steampowered.com/192.168.16.2
    address=/content4.steampowered.com/192.168.16.2
    address=/content5.steampowered.com/192.168.16.2
    address=/content6.steampowered.com/192.168.16.2
    address=/content7.steampowered.com/192.168.16.2
    address=/content8.steampowered.com/192.168.16.2
    address=/cs.steampowered.com/192.168.16.2
    address=/steamcontent.com/192.168.16.2
    address=/client-download.steampowered.com/192.168.16.2
    address=/.hsar.steampowered.com.edgesuite.net/192.168.16.2
    address=/.akamai.steamstatic.com/192.168.16.2
    address=/content-origin.steampowered.com/192.168.16.2
    address=/clientconfig.akamai.steamtransparent.com/192.168.16.2
    address=/steampipe.akamaized.net/192.168.16.2
    address=/edgecast.steamstatic.com/192.168.16.2
    address=/steam.apac.qtlglb.com.mwcloudcdn.com/192.168.16.2
    address=/.cs.steampowered.com/192.168.16.2
    address=/.cm.steampowered.com/192.168.16.2
    address=/.edgecast.steamstatic.com/192.168.16.2
    address=/.steamcontent.com/192.168.16.2
    address=/cdn1-sea1.valve.net/192.168.16.2
    address=/cdn2-sea1.valve.net/192.168.16.2
    address=/.steam-content-dnld-1.apac-1-cdn.cqloud.com/192.168.16.2
    address=/.steam-content-dnld-1.eu-c1-cdn.cqloud.com/192.168.16.2
    address=/.steam-content-dnld-1.qwilted-cds.cqloud.com/192.168.16.2
    address=/steam.apac.qtlglb.com/192.168.16.2
    address=/edge.steam-dns.top.comcast.net/192.168.16.2
    address=/edge.steam-dns-2.top.comcast.net/192.168.16.2
    address=/steam.naeu.qtlglb.com/192.168.16.2
    address=/steampipe-kr.akamaized.net/192.168.16.2
    address=/steam.ix.asn.au/192.168.16.2
    address=/steam.eca.qtlglb.com /192.168.16.2
    address=/steam.cdn.on.net/192.168.16.2
    address=/update5.dota2.wmsj.cn/192.168.16.2
    address=/update2.dota2.wmsj.cn/192.168.16.2
    address=/update6.dota2.wmsj.cn/192.168.16.2
    address=/update3.dota2.wmsj.cn/192.168.16.2
    address=/update1.dota2.wmsj.cn/192.168.16.2
    address=/update4.dota2.wmsj.cn/192.168.16.2
    address=/update5.csgo.wmsj.cn/192.168.16.2
    address=/update2.csgo.wmsj.cn/192.168.16.2
    address=/update4.csgo.wmsj.cn/192.168.16.2
    address=/update3.csgo.wmsj.cn/192.168.16.2
    address=/update6.csgo.wmsj.cn/192.168.16.2
    address=/update1.csgo.wmsj.cn/192.168.16.2
    address=/st.dl.bscstorage.net/192.168.16.2
    address=/cdn.mileweb.cs.steampowered.com.8686c.com/192.168.16.2
    address=/steamcdn-a.akamaihd.net/192.168.16.2

    # Uplay
    address=/.cdn.ubi.com/192.168.16.2

    # XBox Live
    address=/assets1.xboxlive.com/192.168.16.2
    address=/assets2.xboxlive.com/192.168.16.2
    address=/xboxone.loris.llnwd.net/192.168.16.2
    address=/.xboxone.loris.llnwd.net/192.168.16.2
    address=/xboxone.vo.llnwd.net/192.168.16.2
    address=/xbox-mbr.xboxlive.com/192.168.16.2
    address=/assets1.xboxlive.com.nsatc.net/192.168.16.2
    address=/xvcf1.xboxlive.com/192.168.16.2
    address=/xvcf2.xboxlive.com/192.168.16.2
    address=/d1.xboxlive.com/192.168.16.2
  '';
  inherit (piholeUser) uid;
  inherit (piholeUser.group) gid;
  mode = "0444";
}

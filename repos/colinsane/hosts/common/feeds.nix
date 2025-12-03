# where to find good stuff?
# - universal search/directory: <https://podcastindex.org>
#   - the full database is downloadable
# - find adjacent podcasts: <https://rephonic.com/graph>
# - charts: <https://rephonic.com/charts/apple/united-states/technology>
# - list of lists: <https://en.wikipedia.org/wiki/Category:Lists_of_podcasts>
# - podcasts w/ a community: <https://lemmyverse.net/communities?query=podcast>
# - podcast recs:
#   - active lemmy: <https://slrpnk.net/c/podcasts>
#   - old thread: <https://lemmy.ml/post/1565858>
#
# - paywall bypass / bootlegs: <https://jumble.top/>
{ lib, sane-data, ... }:
let
  hourly = { freq = "hourly"; };
  daily = { freq = "daily"; };
  weekly = { freq = "weekly"; };
  infrequent = { freq = "infrequent"; };

  art = { cat = "art"; };
  humor = { cat = "humor"; };
  pol = { cat = "pol"; };  # or maybe just "social"
  rat = { cat = "rat"; };
  tech = { cat = "tech"; };
  uncat = { cat = "uncat"; };

  text = { format = "text"; };
  img = { format = "image"; };

  mkRss = format: url: { inherit url format; } // uncat // infrequent;
  # format-specific helpers
  mkText = mkRss "text";
  mkImg = mkRss "image";
  mkPod = mkRss "podcast";

  # host-specific helpers
  mkSubstack = subdomain: { substack = subdomain; };

  fromDb = name:
    let
      raw = sane-data.feeds."${name}";
    in {
      url = raw.url;
      # not sure the exact mapping with velocity here: entries per day?
      freq = lib.mkIf (raw.velocity or 0 != 0) (lib.mkDefault (
        if raw.velocity > 2 then
          "hourly"
        else if raw.velocity > 0.5 then
          "daily"
        else if raw.velocity > 0.1 then
          "weekly"
        else
          "infrequent"
      ));
    } // lib.optionalAttrs (lib.hasPrefix "https://www.youtube.com/" raw.url) {
      format = "video";
    } // lib.optionalAttrs (raw.is_podcast or false) {
      format = "podcast";
    } // lib.optionalAttrs (raw.title or "" != "") {
      title = lib.mkDefault raw.title;
    };

  podcasts = [
    (fromDb "404media.co/the-404-media-podcast" // tech)
    (fromDb "acquiredlpbonussecretsecret.libsyn.com" // tech)  # ACQ2 - more "Acquired" episodes
    (fromDb "adventofcomputing.com" // tech)  # computing history
    (fromDb "allinchamathjason.libsyn.com" // pol)
    (fromDb "api.oyez.org/podcasts/oral-arguments/2015" // pol)  # Supreme Court Oral Arguments ("2015" in URL means nothing -- it's still updated)
    (fromDb "anchor.fm/s/34c7232c/podcast/rss" // tech)  # Civboot -- https://anchor.fm/civboot
    (fromDb "anchor.fm/s/2da69154/podcast/rss" // tech)  # POD OF JAKE -- https://podofjake.com/
    (fromDb "bluecityblues.org.podcastpage.io" // pol)  # hosts overlap with Seattle Nice
    (fromDb "buzzsprout.com/2126417" // tech)  # Mystery AI Hype Theater 3000
    (fromDb "cast.postmarketos.org" // tech)
    (fromDb "congressionaldish.libsyn.com" // pol)  # Jennifer Briney
    (fromDb "craphound.com" // pol)  # Cory Doctorow -- both podcast & text entries
    (fromDb "darknetdiaries.com" // tech)
    (fromDb "dwarkeshpatel.com" // tech)
    (fromDb "feeds.99percentinvisible.org/99percentinvisible" // pol)  # 99% Invisible -- also available here: <https://feeds.simplecast.com/BqbsxVfO>
    (fromDb "feeds.acast.com/public/shows/lawfare" // pol)  # <https://www.lawfaremedia.org/podcasts-multimedia/podcast/the-lawfare-podcast>
    (fromDb "feeds.buzzsprout.com/2412334.rss")  # Matt Stoller's _Organized Money_ <https://www.organizedmoney.fm/>
    (fromDb "feeds.eff.org/howtofixtheinternet" // pol)
    (fromDb "feeds.feedburner.com/80000HoursPodcast" // rat)
    (fromDb "feeds.feedburner.com/dancarlin/history" // rat)
    (fromDb "feeds.feedburner.com/radiolab" // pol)  # Radiolab -- also available here, but ONLY OVER HTTP: <http://feeds.wnyc.org/radiolab>
    (fromDb "feeds.megaphone.fm/CHTAL4990341033" // pol)  # ChinaTalk: https://www.chinatalk.media/podcast
    (fromDb "feeds.megaphone.fm/GLT1412515089" // pol)  # JRE: Joe Rogan Experience
    (fromDb "feeds.megaphone.fm/behindthebastards" // pol)  # also Maggie Killjoy
    (fromDb "feeds.megaphone.fm/cspantheweekly" // pol)
    (fromDb "feeds.megaphone.fm/econ102")  # Noah Smith + Erik Torenberg <https://www.podpage.com/econ102/>
    (fromDb "feeds.megaphone.fm/history102")  # <https://www.podpage.com/history-102-with-whatifalthist/>
    (fromDb "feeds.megaphone.fm/recodedecode" // tech)  # The Verge - Decoder
    (fromDb "feeds.megaphone.fm/thiswontlast" // tech)  # <https://www.podpage.com/thiswontlast/>
    (fromDb "feeds.megaphone.fm/unexplainable")
    (fromDb "feeds.simplecast.com/wgl4xEgL" // rat)  # Econ Talk
    (fromDb "feeds.transistor.fm/acquired" // tech)
    (fromDb "feeds.transistor.fm/complex-systems-with-patrick-mckenzie-patio11" // tech)  # Patrick Mackenzie (from Bits About Money)
    (fromDb "feeds.twit.tv/floss.xml" // tech)
    (fromDb "fulltimenix.com" // tech)
    (fromDb "futureofcoding.org/episodes" // tech)
    (fromDb "hackerpublicradio.org" // tech)
    (fromDb "jumble.top/f/srslywrong.xml" // pol)  # srslywrong.com patreon feed
    (fromDb "lexfridman.com/podcast" // rat)
    (fromDb "linktr.ee/betteroffline" // pol)
    (fromDb "linuxdevtime.com" // tech)
    (fromDb "malicious.life" // tech)
    (fromDb "mapspodcast.libsyn.com" // uncat)  # Multidisciplinary Association for Psychedelic Studies
    (fromDb "motherearthnewsandfriends.libsyn.com" // uncat)  # off-grid living
    (fromDb "microarch.club" // tech)
    (fromDb "nocturnepodcast.org")
    (fromDb "omegataupodcast.net" // tech)  # 3/4 German; 1/4 eps are English
    (fromDb "omny.fm/shows/cool-people-who-did-cool-stuff" // pol)  # Maggie Killjoy -- referenced by Cory Doctorow
    (fromDb "omny.fm/shows/money-stuff-the-podcast")  # Matt Levine
    (fromDb "omny.fm/shows/stuff-you-should-know-1")
    (fromDb "omny.fm/shows/weird-little-guys")  # Cool Zone Media
    (fromDb "originstories.libsyn.com" // uncat)
    (fromDb "podcast.ergaster.org/@flintandsilicon" // tech)  # Thib's podcast: public interest tech, gnome, etc: <https://fed.uninsane.org/users/$ALLO9MZ5g5CsQTCBH6>
    (fromDb "pods.media/api/rss/feed/channel/unchained" // tech)  # cryptocurrency happenings; rec via patio11
    (fromDb "politicalorphanage.libsyn.com" // pol)
    (fromDb "reverseengineering.libsyn.com/rss" // tech)  # UnNamed Reverse Engineering Podcast
    (fromDb "rss.acast.com/ft-tech-tonic" // tech)  # Financial Time's: Tech Tonic
    (fromDb "rss.art19.com/the-portal" // rat)  # Eric Weinstein
    (fromDb "seattlenice.buzzsprout.com" // pol)  # Seattle Nice
    (fromDb "speedboatdope.com" // pol)  # Chapo Trap House (premium feed)
    (fromDb "sharkbytes.transistor.fm" // tech)  # Wireshark Podcast o_0
    (fromDb "sharptech.fm/feed/podcast" // tech)  # Ben Thompson
    (fromDb "sscpodcast.libsyn.com" // rat)  # Astral Codex Ten; Scott Alexander
    (fromDb "talesfromthebridge.buzzsprout.com" // tech)  # Sci-Fi? has Peter Watts; author of No Moods, Ads or Cutesy Fucking Icons (rifters.com)
    (fromDb "techtalesshow.com" // tech)  # Corbin Davenport
    (fromDb "theamphour.com" // tech)  # The Amp Hour
    (fromDb "theboilingfrog.net" // pol)
    (fromDb "thefinalstrawradio.noblogs.org/podcasting" // pol)
    (fromDb "the-ben-marc-show.simplecast.com" // tech // pol)  # Ben Horowitz + Marc Andreessen; love to hate em
    (fromDb "timclicks.dev/compose-podcast" // tech)  # Rust-heavy dev interviews
    (fromDb "werenotwrong.fireside.fm" // pol)  # We're Not Wrong
    (fromDb "whycast.podcast.audio/@whycast" // tech)  # What Hackers Yearn [for]: <https://why2025.org/>
    (mkPod "https://sfconservancy.org/casts/the-corresponding-source/feeds/ogg/" // tech)

    # (fromDb "feed.podbean.com/matrixlive/feed.xml" // tech)  # Matrix (chat) Live
    # (fromDb "feeds.libsyn.com/421877" // rat)  # Less Wrong Curated
    # (fromDb "feeds.megaphone.fm/hubermanlab" // uncat)  # Daniel Huberman on sleep
    # (fromDb "feeds.simplecast.com/54nAGcIl" // pol)  # The Daily
    # (fromDb "feeds.simplecast.com/82FI35Px" // pol)  # Ezra Klein Show
    # (fromDb "feeds.simplecast.com/l2i9YnTd" // tech // pol)  # Hard Fork (NYtimes tech)
    # (fromDb "feeds.simplecast.com/whlwDbyc" // tech)  # Tech Lounge: <https://chrischinchilla.com/podcast/techlounge/>
    # (fromDb "feeds.simplecast.com/xKJ93w_w" // uncat)  # Atlas Obscura
    # (fromDb "iheart.com/podcast/1119-away-days-podcast-reporti-275359753" // pol)  # Away Days (Cool Zone Media)
    # (fromDb "jumble.top/f/thedollop.xml")  # The Dollop history/comedy (patreon feed)
    # (fromDb "lastweekinai.com" // tech)  # Last Week in AI
    # (fromDb "mintcast.org" // tech)
    # (fromDb "omny.fm/shows/sad-oligarch")
    # (fromDb "omny.fm/shows/the-dollop-with-dave-anthony-and-gareth-reynolds")  # The Dollop history/comedy
    # (fromDb "podcast.posttv.com/itunes/post-reports.xml" // pol)
    # (fromDb "podcast.sustainoss.org" // tech)  # "Sustainable tech", only... it somehow manages to avoid any tech which is actually sustainable, and most of the time doesn't even talk about Open Source Software (!). normie/surface-level/"feel good"
    # (fromDb "podcast.thelinuxexp.com" // tech)  # low-brow linux/foss PR announcements
    # (fromDb "politicspoliticspolitics.com" // pol)  # don't judge me. Justin Robert Young.
    # (fromDb "rss.acast.com/deconstructed")  # The Intercept - Deconstructed
    # (fromDb "rss.acast.com/intercepted-with-jeremy-scahill")  # The Intercept - Intercepted
    # (fromDb "rss.art19.com/60-minutes" // pol)
    # (fromDb "rss.art19.com/your-welcome" // pol)  # Michael Malice - Your Welcome -- also available here: <https://origin.podcastone.com/podcast?categoryID2=2232>
    # (fromDb "rss.prod.firstlook.media/deconstructed/podcast.rss" // pol)  #< possible URL rot
    # (fromDb "rss.prod.firstlook.media/intercepted/podcast.rss" // pol)  #< possible URL rot
    # (fromDb "sites.libsyn.com/438684" // humor)  # Quorators - digging up *weird* Quota questions
    # (fromDb "srslywrong.com" // pol)
    # (fromDb "techwontsave.us" // pol)  # rec by Cory Doctorow, but way too info-sparse
    # (fromDb "trashfuturepodcast.podbean.com" // pol)  # rec by Cory Doctorow, but way rambly
    # (fromDb "wakingup.libsyn.com" // pol)  # Sam Harris, but he just repeats himself now
    # (mkPod "https://anchor.fm/s/21bc734/podcast/rss" // pol // infrequent)  # Emerge: making sense of what's next -- <https://www.whatisemerging.com/emergepodcast>
    # (mkPod "https://audioboom.com/channels/5097784.rss" // tech)  # Lateral with Tom Scott
    # (mkPod "https://feeds.megaphone.fm/RUNMED9919162779" // pol // infrequent)  # The Witch Trials of J.K. Rowling: <https://www.thefp.com/witchtrials>
    # (mkPod "https://podcasts.la.utexas.edu/this-is-democracy/feed/podcast/" // pol // weekly)
  ];

  texts = [
    (fromDb "ergaster.org/blog" // tech)  # Thib's blog: public interest tech, gnome, etc: <https://fed.uninsane.org/users/$ALLO9MZ5g5CsQTCBH6>
    (fromDb "acoup.blog/feed")  # history, states. author: <https://historians.social/@bretdevereaux/following>
    (fromDb "amosbbatto.wordpress.com" // tech)
    (fromDb "anish.lakhwara.com" // tech)
    (fromDb "antipope.org")  # Charles Stross
    (fromDb "apenwarr.ca/log/rss.php" // tech)  # CEO of tailscale
    (fromDb "applieddivinitystudies.com" // rat)
    (fromDb "artemis.sh" // tech)
    (fromDb "ascii.textfiles.com" // tech)  # Jason Scott
    (fromDb "austinvernon.site" // tech)
    (fromDb "buttondown.email" // tech)
    (fromDb "ben-evans.com/benedictevans" // pol)
    (fromDb "bitbashing.io" // tech)
    (fromDb "bitsaboutmoney.com" // uncat)
    (fromDb "blog.danieljanus.pl" // tech)
    (fromDb "blog.dshr.org" // pol)  # David Rosenthal
    (fromDb "blog.jmp.chat" // tech)
    (fromDb "blog.rust-lang.org" // tech)
    (fromDb "blog.thalheim.io" // tech)  # Mic92
    (fromDb "blog.brixit.nl" // tech)  # Martijn Braam
    (fromDb "bunniestudios.com" // tech)  # Bunnie Juang
    (fromDb "capitolhillseattle.com" // pol)
    (fromDb "edwardsnowden.substack.com" // pol // text)
    (fromDb "fasterthanli.me" // tech)
    (fromDb "gwern.net" // rat)
    (fromDb "hardcoresoftware.learningbyshipping.com" // tech)  # Steven Sinofsky
    (fromDb "harihareswara.net" // tech // pol)  # rec by Cory Doctorow
    (fromDb "ianthehenry.com" // tech)
    (fromDb "idiomdrottning.org" // uncat)
    (fromDb "interconnected.org/home/feed" // rat)  # Matt Webb -- engineering-ish, but dreamy
    (fromDb "jeffgeerling.com" // tech)
    (fromDb "jefftk.com" // tech)
    (fromDb "justine.lol" // tech)
    (fromDb "jwz.org/blog" // tech // pol)  # DNA lounge guy, loooong-time blogger
    (fromDb "kill-the-newsletter.com/feeds/joh91bv7am2pnznv.xml" // pol)  # Matt Levine - Money Stuff
    (fromDb "kosmosghost.github.io/index.xml" // tech)
    (fromDb "linmob.net" // tech)
    (fromDb "lwn.net" // tech)
    (fromDb "lynalden.com" // pol)
    (fromDb "mako.cc/copyrighteous" // tech // pol)  # rec by Cory Doctorow
    (fromDb "mg.lol" // tech)
    (fromDb "mindingourway.com" // rat)
    (fromDb "momi.ca" // tech)  # Anjan, pmOS
    (fromDb "morningbrew.com/feed" // pol)
    (fromDb "nixpkgs.news" // tech)
    (fromDb "overcomingbias.com" // rat)  # Robin Hanson
    (fromDb "palladiummag.com" // uncat)
    (fromDb "philosopher.coach" // rat)  # Peter Saint-Andre -- side project of stpeter.im
    (fromDb "pomeroyb.com" // tech)
    (fromDb "postmarketos.org/blog" // tech)
    (fromDb "preposterousuniverse.com" // rat)  # Sean Carroll
    (fromDb "project-insanity.org" // tech)  # shared blog by a few NixOS devs, notably onny
    (fromDb "putanumonit.com" // rat)  # mostly dating topics. not advice, or humor, but looking through a social lens
    (fromDb "richardcarrier.info" // rat)
    (fromDb "rifters.com/crawl" // uncat)  # No Moods, Ads or Cutesy Fucking Icons
    (fromDb "righto.com" // tech)  # Ken Shirriff
    (fromDb "rootsofprogress.org" // rat)  # Jason Crawford
    (fromDb "samuel.dionne-riel.com" // tech)  # SamuelDR
    (fromDb "sagacioussuricata.com" // tech)  # ian (Sanctuary)
    (fromDb "semiaccurate.com" // tech)
    (fromDb "sideways-view.com" // rat)  # Paul Christiano
    (fromDb "slatecave.net" // tech)
    (fromDb "slimemoldtimemold.com" // rat)
    (fromDb "spectrum.ieee.org" // tech)
    (fromDb "stpeter.im/atom.xml" // pol)
    (fromDb "thisweek.gnome.org" // tech)
    (fromDb "tuxphones.com" // tech)
    (fromDb "uninsane.org" // tech)
    (fromDb "unintendedconsequenc.es" // rat)
    (fromDb "vitalik.eth.limo" // tech)  # Vitalik Buterin
    (fromDb "weekinethereumnews.com" // tech)
    (fromDb "willow.phantoma.online")  # wizard@xyzzy.link
    (fromDb "xn--gckvb8fzb.com" // tech)
    (fromDb "xorvoid.com" // tech)
    (fromDb "www.thebignewsletter.com" // pol)
    (mkSubstack "astralcodexten" // rat // daily)  # Scott Alexander
    (mkSubstack "chlamchowder" // tech)  # details CPU advancements
    (mkSubstack "eliqian" // rat // weekly)
    (mkSubstack "oversharing" // pol // daily)
    (mkSubstack "samkriss" // humor // infrequent)
    (mkText "http://benjaminrosshoffman.com/feed" // pol // weekly)
    (mkText "http://boginjr.com/feed" // tech // infrequent)
    (mkText "https://forum.merveilles.town/rss.xml" // pol // infrequent)  #quality RSS list here: <https://forum.merveilles.town/thread/57/share-your-rss-feeds%21-6/>
    (mkText "https://icm.museum/rss20.xml" // tech // infrequent)  # Interim Computer Museum
    (mkText "https://jvns.ca/atom.xml" // tech // weekly)  # Julia Evans
    (mkText "https://linuxphoneapps.org/blog/atom.xml" // tech // infrequent)
    (mkText "https://nixos.org/blog/announcements-rss.xml" // tech // infrequent)  # more nixos stuff here, but unclear how to subscribe: <https://nixos.org/blog/categories.html>
    (mkText "https://nixos.org/blog/stories-rss.xml" // tech // weekly)
    (mkText "https://solar.lowtechmagazine.com/posts/index.xml" // tech // weekly)
    (mkText "https://www.stratechery.com/rss" // pol // weekly)  # Ben Thompson

    # (fromDb "balajis.com" // pol)  # Balaji
    # (fromDb "drewdevault.com" // tech)
    # (fromDb "econlib.org" // pol)
    # (fromDb "lesswrong.com" // rat)
    # (fromDb "profectusmag.com" // pol)  # some conservative/libertarian think tank
    # (fromDb "thediff.co" // pol)  # Byrne Hobart; 80% is subscriber-only
    # (fromDb "thesideview.co" // uncat)  # spiritual journal; RSS items are stubs
    # (fromDb "theregister.com" // tech)
    # (fromDb "vitalik.ca" // tech)  # moved to vitalik.eth.limo
    # (fromDb "webcurious.co.uk" // uncat)  # link aggregator; defunct?
    # (mkSubstack "doomberg" // tech // weekly)  # articles are all pay-walled
    # (mkText "https://github.com/Kaiteki-Fedi/Kaiteki/commits/master.atom" // tech // infrequent)
    # (mkText "https://til.simonwillison.net/tils/feed.atom" // tech // weekly)
    # (mkText "https://www.bloomberg.com/opinion/authors/ARbTQlRLRjE/matthew-s-levine.rss" // pol // weekly)  # Matt Levine (preview/paywalled)
  ];

  videos = [
    (fromDb "youtube.com/@Channel5YouTube" // pol)
    (fromDb "youtube.com/@ContraPoints" // pol)
    (fromDb "youtube.com/@Exurb1a")
    (fromDb "youtube.com/@hbomberguy")
    (fromDb "youtube.com/@JackStauber")
    (fromDb "youtube.com/@jaketran")
    (fromDb "youtube.com/@kurzgesagt")
    (fromDb "youtube.com/@mii_beta" // tech)  # Baby Wogue / gnome reviewer
    (fromDb "youtube.com/@Matrixdotorg" // tech)  # Matrix Live
    (fromDb "youtube.com/@NativLang")
    (fromDb "youtube.com/@PolyMatter")
    (fromDb "youtube.com/@scenesbyben" // pol)  # video essays
    (fromDb "youtube.com/@TechnologyConnections" // tech)
    (fromDb "youtube.com/@theodd1sout")
    (fromDb "youtube.com/@TomScottGo")
    (fromDb "youtube.com/@TVW_Washington" // pol)  # interviews with WA public officials
    (fromDb "youtube.com/@veritasium")
    (fromDb "youtube.com/@Vihart")
    (fromDb "youtube.com/@InnuendoStudios" // pol)  # breaks down the nastier political strategies, from a "politics is power" angle

    # (fromDb "youtube.com/@CasuallyExplained" // pol)
    # (fromDb "youtube.com/@ColdFusion")
    # (fromDb "youtube.com/@rossmanngroup" // pol // tech)  # Louis Rossmann
    # (fromDb "youtube.com/@TheB1M")
    # (fromDb "youtube.com/@tested" // tech)  # Adam Savage  (uploads too frequently)
    # (fromDb "youtube.com/@Vox")
    # (fromDb "youtube.com/@Vsauce")  # they're all like 1-minute long videos now? what happened @Vsauce?
  ];

  images = [
    (fromDb "catandgirl.com" // img // humor)
    (fromDb "davidrevoy.com" // img // art)
    (fromDb "grumpy.website" // img // humor)
    (fromDb "miniature-calendar.com" // img // art // daily)
    (fromDb "pbfcomics.com" // img // humor)
    (fromDb "poorlydrawnlines.com/feed" // img // humor)
    (fromDb "smbc-comics.com" // img // humor)
    (fromDb "turnoff.us" // img // humor)
    (fromDb "xkcd.com" // img // humor)
  ];
in
{
  sane.feeds = texts ++ images ++ podcasts ++ videos;

  assertions = builtins.map
    (p: {
      assertion = p.format or "unknown" == "podcast";
      message = ''${p.url} is not a podcast: ${p.format or "unknown"}'';
    })
    podcasts;
}

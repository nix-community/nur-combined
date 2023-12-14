# where to find good stuff?
# - podcasts w/ a community: <https://lemmyverse.net/communities?query=podcast>
# - podcast rec thread: <https://lemmy.ml/post/1565858>
#
# candidates:
# - The Nonlinear Library (podcast): <https://forum.effectivealtruism.org/posts/JTZTBienqWEAjGDRv/listen-to-more-ea-content-with-the-nonlinear-library>
#   - has ~10 posts per day, text-to-speech; i would need better tagging before adding this
# - <https://www.metaculus.com/questions/11102/introducing-the-metaculus-journal-podcast/>
#   - dead since 2022/10 - 2023/03

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
    (fromDb "acquiredlpbonussecretsecret.libsyn.com" // tech)  # ACQ2 - more "Acquired" episodes
    (fromDb "allinchamathjason.libsyn.com" // pol)
    (fromDb "anchor.fm/s/34c7232c/podcast/rss" // tech)  # Civboot -- https://anchor.fm/civboot
    (fromDb "cast.postmarketos.org" // tech)
    (fromDb "congressionaldish.libsyn.com" // pol)  # Jennifer Briney
    (fromDb "craphound.com" // pol)  # Cory Doctorow -- both podcast & text entries
    (fromDb "darknetdiaries.com" // tech)
    (fromDb "feed.podbean.com/matrixlive/feed.xml" // tech)  # Matrix (chat) Live
    (fromDb "feeds.99percentinvisible.org/99percentinvisible" // pol)  # 99% Invisible -- also available here: <https://feeds.simplecast.com/BqbsxVfO>
    (fromDb "feeds.feedburner.com/80000HoursPodcast" // rat)
    (fromDb "feeds.feedburner.com/dancarlin/history" // rat)
    (fromDb "feeds.feedburner.com/radiolab" // pol)  # Radiolab -- also available here, but ONLY OVER HTTP: <http://feeds.wnyc.org/radiolab>
    (fromDb "feeds.libsyn.com/421877" // rat)  # Less Wrong Curated
    (fromDb "feeds.megaphone.fm/behindthebastards" // pol)  # also Maggie Killjoy
    # (fromDb "feeds.megaphone.fm/hubermanlab" // uncat)  # Daniel Huberman on sleep
    (fromDb "feeds.megaphone.fm/recodedecode" // tech)  # The Verge - Decoder
    (fromDb "feeds.simplecast.com/54nAGcIl" // pol)  # The Daily
    (fromDb "feeds.simplecast.com/82FI35Px" // pol)  # Ezra Klein Show
    (fromDb "feeds.simplecast.com/wgl4xEgL" // rat)  # Econ Talk
    (fromDb "feeds.simplecast.com/xKJ93w_w" // uncat)  # Atlas Obscura
    # (fromDb "feeds.simplecast.com/l2i9YnTd" // tech // pol)  # Hard Fork (NYtimes tech)
    (fromDb "feeds.transistor.fm/acquired" // tech)
    (fromDb "lexfridman.com/podcast" // rat)
    (fromDb "mapspodcast.libsyn.com" // uncat)  # Multidisciplinary Association for Psychedelic Studies
    (fromDb "omegataupodcast.net" // tech)  # 3/4 German; 1/4 eps are English
    (fromDb "omny.fm/shows/cool-people-who-did-cool-stuff" // pol)  # Maggie Killjoy -- referenced by Cory Doctorow
    (fromDb "originstories.libsyn.com" // uncat)
    (fromDb "podcast.posttv.com/itunes/post-reports.xml" // pol)
    (fromDb "podcast.thelinuxexp.com" // tech)
    (fromDb "politicalorphanage.libsyn.com" // pol)
    (fromDb "reverseengineering.libsyn.com/rss" // tech)  # UnNamed Reverse Engineering Podcast
    (fromDb "rss.acast.com/deconstructed")  # The Intercept - Deconstructed
    (fromDb "rss.acast.com/ft-tech-tonic" // tech)
    (fromDb "rss.acast.com/intercepted-with-jeremy-scahill")  # The Intercept - Intercepted
    (fromDb "rss.art19.com/60-minutes" // pol)
    (fromDb "rss.art19.com/the-portal" // rat)  # Eric Weinstein
    (fromDb "seattlenice.buzzsprout.com" // pol)
    (fromDb "srslywrong.com" // pol)
    (fromDb "sharkbytes.transistor.fm" // tech)  # Wireshark Podcast o_0
    (fromDb "sscpodcast.libsyn.com" // rat)  # Astral Codex Ten
    (fromDb "talesfromthebridge.buzzsprout.com" // tech)  # Sci-Fi? has Peter Watts; author of No Moods, Ads or Cutesy Fucking Icons (rifters.com)
    (fromDb "techwontsave.us" // pol)  # rec by Cory Doctorow
    # (fromDb "trashfuturepodcast.podbean.com" // pol)  # rec by Cory Doctorow, but way rambly
    (fromDb "wakingup.libsyn.com" // pol)  # Sam Harris
    (fromDb "werenotwrong.fireside.fm" // pol)

    # (fromDb "rss.art19.com/your-welcome" // pol)  # Michael Malice - Your Welcome -- also available here: <https://origin.podcastone.com/podcast?categoryID2=2232>
    # (fromDb "rss.prod.firstlook.media/deconstructed/podcast.rss" // pol)  #< possible URL rot
    # (fromDb "rss.prod.firstlook.media/intercepted/podcast.rss" // pol)  #< possible URL rot
    # (mkPod "https://anchor.fm/s/21bc734/podcast/rss" // pol // infrequent)  # Emerge: making sense of what's next -- <https://www.whatisemerging.com/emergepodcast>
    # (mkPod "https://audioboom.com/channels/5097784.rss" // tech)  # Lateral with Tom Scott
    # (mkPod "https://feeds.megaphone.fm/RUNMED9919162779" // pol // infrequent)  # The Witch Trials of J.K. Rowling: <https://www.thefp.com/witchtrials>
    # (mkPod "https://podcasts.la.utexas.edu/this-is-democracy/feed/podcast/" // pol // weekly)
  ];

  texts = [
    # AGGREGATORS (> 1 post/day)
    (fromDb "lwn.net" // tech)
    # (fromDb "lesswrong.com" // rat)
    # (fromDb "econlib.org" // pol)

    # AGGREGATORS (< 1 post/day)
    (fromDb "palladiummag.com" // uncat)
    (fromDb "profectusmag.com" // uncat)
    (fromDb "semiaccurate.com" // tech)
    (mkText "https://linuxphoneapps.org/blog/atom.xml" // tech // infrequent)
    (fromDb "tuxphones.com" // tech)
    (fromDb "spectrum.ieee.org" // tech)
    # (fromDb "theregister.com" // tech)
    (fromDb "thisweek.gnome.org" // tech)
    # more nixos stuff here, but unclear how to subscribe: <https://nixos.org/blog/categories.html>
    (mkText "https://nixos.org/blog/announcements-rss.xml" // tech // infrequent)
    (mkText "https://nixos.org/blog/stories-rss.xml" // tech // weekly)
    ## n.b.: quality RSS list here: <https://forum.merveilles.town/thread/57/share-your-rss-feeds%21-6/>
    (mkText "https://forum.merveilles.town/rss.xml" // pol // infrequent)

    ## No Moods, Ads or Cutesy Fucking Icons
    (fromDb "rifters.com/crawl" // uncat)
    (fromDb "bitsaboutmoney.com" // uncat)

    # DEVELOPERS
    (fromDb "blog.jmp.chat" // tech)
    (fromDb "uninsane.org" // tech)
    (fromDb "blog.thalheim.io" // tech)  # Mic92
    (fromDb "ascii.textfiles.com" // tech)  # Jason Scott
    (fromDb "xn--gckvb8fzb.com" // tech)
    (fromDb "amosbbatto.wordpress.com" // tech)
    (fromDb "fasterthanli.me" // tech)
    (fromDb "jeffgeerling.com" // tech)
    (fromDb "kosmosghost.github.io/index.xml" // tech)
    (fromDb "mg.lol" // tech)
    # (fromDb "drewdevault.com" // tech)
    ## Ken Shirriff
    (fromDb "righto.com" // tech)
    ## shared blog by a few NixOS devs, notably onny
    (fromDb "project-insanity.org" // tech)
    ## Vitalik Buterin
    (fromDb "vitalik.ca" // tech)
    ## ian (Sanctuary)
    (fromDb "sagacioussuricata.com" // tech)
    (fromDb "artemis.sh" // tech)
    ## Bunnie Juang
    (fromDb "bunniestudios.com" // tech)
    (fromDb "blog.danieljanus.pl" // tech)
    (fromDb "ianthehenry.com" // tech)
    (fromDb "bitbashing.io" // tech)
    (fromDb "idiomdrottning.org" // uncat)
    (mkText "http://boginjr.com/feed" // tech // infrequent)
    (mkText "https://anish.lakhwara.com/home.html" // tech // weekly)
    (fromDb "jefftk.com" // tech)
    (fromDb "pomeroyb.com" // tech)
    (fromDb "harihareswara.net" // tech // pol)  # rec by Cory Doctorow
    (fromDb "mako.cc/copyrighteous" // tech // pol)  # rec by Cory Doctorow
    # (mkText "https://til.simonwillison.net/tils/feed.atom" // tech // weekly)

    # TECH PROJECTS
    (fromDb "blog.rust-lang.org" // tech)
    (fromDb "linmob.net" // tech)

    # (TECH; POL) COMMENTATORS
    ## Matt Webb -- engineering-ish, but dreamy
    (fromDb "interconnected.org/home/feed" // rat)
    (fromDb "edwardsnowden.substack.com" // pol // text)
    ## Julia Evans
    (mkText "https://jvns.ca/atom.xml" // tech // weekly)
    (mkText "http://benjaminrosshoffman.com/feed" // pol // weekly)
    ## Ben Thompson
    (mkText "https://www.stratechery.com/rss" // pol // weekly)
    ## Balaji
    (fromDb "balajis.com" // pol)
    (fromDb "ben-evans.com/benedictevans" // pol)
    (fromDb "lynalden.com" // pol)
    (fromDb "austinvernon.site" // tech)
    (mkSubstack "oversharing" // pol // daily)
    (mkSubstack "byrnehobart" // pol // infrequent)
    # (mkSubstack "doomberg" // tech // weekly)  # articles are all pay-walled
    ## David Rosenthal
    (fromDb "blog.dshr.org" // pol)
    ## Matt Levine
    (mkText "https://www.bloomberg.com/opinion/authors/ARbTQlRLRjE/matthew-s-levine.rss" // pol // weekly)
    (fromDb "stpeter.im/atom.xml" // pol)
    ## Peter Saint-Andre -- side project of stpeter.im
    (fromDb "philosopher.coach" // rat)
    (fromDb "morningbrew.com/feed" // pol)

    # RATIONALITY/PHILOSOPHY/ETC
    (mkSubstack "samkriss" // humor // infrequent)
    (fromDb "unintendedconsequenc.es" // rat)
    (fromDb "applieddivinitystudies.com" // rat)
    (fromDb "slimemoldtimemold.com" // rat)
    (fromDb "richardcarrier.info" // rat)
    (fromDb "gwern.net" // rat)
    ## Jason Crawford
    (fromDb "rootsofprogress.org" // rat)
    ## Robin Hanson
    (fromDb "overcomingbias.com" // rat)
    ## Scott Alexander
    (mkSubstack "astralcodexten" // rat // daily)
    ## Paul Christiano
    (fromDb "sideways-view.com" // rat)
    ## Sean Carroll
    (fromDb "preposterousuniverse.com" // rat)
    (mkSubstack "eliqian" // rat // weekly)
    (mkText "https://acoup.blog/feed" // rat // weekly)
    (fromDb "mindingourway.com" // rat)

    ## mostly dating topics. not advice, or humor, but looking through a social lens
    (fromDb "putanumonit.com" // rat)

    # LOCAL
    (fromDb "capitolhillseattle.com" // pol)

    # CODE
    # (mkText "https://github.com/Kaiteki-Fedi/Kaiteki/commits/master.atom" // tech // infrequent)
  ];

  videos = [
    (fromDb "youtube.com/@Channel5YouTube" // pol)
    (fromDb "youtube.com/@ColdFusion")
    (fromDb "youtube.com/@ContraPoints" // pol)
    (fromDb "youtube.com/@Exurb1a")
    (fromDb "youtube.com/@PolyMatter")
    (fromDb "youtube.com/@rossmanngroup" // pol // tech)  # Louis Rossmann
    (fromDb "youtube.com/@TechnologyConnections" // tech)
    (fromDb "youtube.com/@TheB1M")
    (fromDb "youtube.com/@TomScottGo")
    (fromDb "youtube.com/@Vihart")
    (fromDb "youtube.com/@Vox")
    (fromDb "youtube.com/@Vsauce")
    (fromDb "youtube.com/@hbomberguy")
  ];

  images = [
    (fromDb "smbc-comics.com" // img // humor)
    (fromDb "xkcd.com" // img // humor)
    (fromDb "turnoff.us" // img // humor)
    (fromDb "pbfcomics.com" // img // humor)
    # (mkImg "http://dilbert.com/feed" // humor // daily)
    (fromDb "poorlydrawnlines.com/feed" // img // humor)

    # ART
    (fromDb "miniature-calendar.com" // img // art // daily)
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

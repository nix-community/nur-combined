{
  mbtileserver = ./services/mbtileserver.nix;

  home-manager = {
    programs = {
      goldendict = ./home-manager/programs/goldendict.nix;
      gpxsee = ./home-manager/programs/gpxsee.nix;
      josm = ./home-manager/programs/josm.nix;
      merkaartor = ./home-manager/programs/merkaartor.nix;
      openorienteering-mapper = ./home-manager/programs/openorienteering-mapper.nix;
      qmapshack = ./home-manager/programs/qmapshack.nix;
      slack-term = ./home-manager/programs/slack-term.nix;
    };
  };
}

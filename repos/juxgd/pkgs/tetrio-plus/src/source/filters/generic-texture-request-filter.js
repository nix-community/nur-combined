let keys = [
  { key: 'board', url: 'skins/board/generic/board.png' },
  { key: 'queue', url: 'skins/board/generic/queue.png' },
  { key: 'grid', url: 'skins/board/generic/grid.png' },
  { key: 'particle_beam', url: 'particles/beam.png' },
  { key: 'particle_beams_beam', url: 'particles/beams/beam.png' },
  { key: 'particle_bigbox', url: 'particles/bigbox.png' },
  { key: 'particle_box', url: 'particles/box.png' },
  { key: 'particle_chip', url: 'particles/chip.png' },
  { key: 'particle_chirp', url: 'particles/chirp.png' },
  { key: 'particle_dust', url: 'particles/dust.png' },
  { key: 'particle_fbox', url: 'particles/fbox.png' },
  { key: 'particle_fire', url: 'particles/fire.png' },
  { key: 'particle_particle', url: 'particles/particle.png' },
  { key: 'particle_smoke', url: 'particles/smoke.png' },
  { key: 'particle_star', url: 'particles/star.png' },
  { key: 'particle_flake', url: 'particles/flake.png' },
  { key: 'rank_d', url: 'league-ranks/d.png' },
  { key: 'rank_dplus', url: 'league-ranks/d+.png' },
  { key: 'rank_cminus', url: 'league-ranks/c-.png' },
  { key: 'rank_c', url: 'league-ranks/c.png' },
  { key: 'rank_cplus', url: 'league-ranks/c+.png' },
  { key: 'rank_bminus', url: 'league-ranks/b-.png' },
  { key: 'rank_b', url: 'league-ranks/b.png' },
  { key: 'rank_bplus', url: 'league-ranks/b+.png' },
  { key: 'rank_aminus', url: 'league-ranks/a-.png' },
  { key: 'rank_a', url: 'league-ranks/a.png' },
  { key: 'rank_aplus', url: 'league-ranks/a+.png' },
  { key: 'rank_sminus', url: 'league-ranks/s-.png' },
  { key: 'rank_s', url: 'league-ranks/s.png' },
  { key: 'rank_splus', url: 'league-ranks/s+.png' },
  { key: 'rank_ss', url: 'league-ranks/ss.png' },
  { key: 'rank_u', url: 'league-ranks/u.png' },
  { key: 'rank_x', url: 'league-ranks/x.png' },
  { key: 'rank_xplus', url: 'league-ranks/x+.png' },
  { key: 'rank_z', url: 'league-ranks/z.png' },
  { key: 'font_hun_png', url: 'font/hun.png' },
  { key: 'font_hun_fnt', url: 'font/hun.fnt' },
  { key: 'achievements', url: 'achievements/icons.png'},
  { key: 'zenith', url: 'skins/board/zenith/base.png' },
  { key: 'zenith_2x', url: 'skins/board/zenith/base.2x.png' },
  { key: 'zenith_rank', url: 'skins/board/zenith/zenithrank.png' },
  { key: 'zenith_expert', url: 'skins/board/zenith/expert.png' },
  { key: 'zenith_expert_2x', url: 'skins/board/zenith/expert.2x.png' },
  { key: 'zenith_duoleft', url: 'skins/board/zenith/duoleft.png' },
  { key: 'zenith_duoleft_2x', url: 'skins/board/zenith/duoleft.2x.png' },
  { key: 'zenith_duoright', url: 'skins/board/zenith/duoright.png' },
  { key: 'zenith_duoright_2x', url: 'skins/board/zenith/duoright.2x.png' },
  { key: 'zenith_expert_duoleft', url: 'skins/board/zenith/expert-duoleft.png' },
  { key: 'zenith_expert_duoleft_2x', url: 'skins/board/zenith/expert-duoleft.2x.png' },
  { key: 'zenith_expert_duoright', url: 'skins/board/zenith/expert-duoright.png' },
  { key: 'zenith_expert_duoright_2x', url: 'skins/board/zenith/expert-duoright.2x.png' },

  { key: 'winter2022board', url: 'skins/board/frosty2022/board.png' },
  { key: 'winter2022queue', url: 'skins/board/frosty2022/queue.png' },
  
  { key: 'frosty2023board', url: 'skins/board/frosty2023/board.png' },
  { key: 'frosty2023queue', url: 'skins/board/frosty2023/queue.png' },
  { key: 'frosty2023grid', url: 'skins/board/frosty2023/grid.png' },
  { key: 'frosty2023snowcaps', url: 'frosty2023-snowcaps.png' },
  
  { key: 'grid', url: 'skins/board/frosty2022/grid.png' }
];

for (let { key, url } of keys) {
  createRewriteFilter(`Texture asset: ${key}`, 'https://tetr.io/res/' + url + '*', {
    enabledFor: async (storage, url) => {
      let res = await storage.get(key);
      return !!res[key];
    },
    onStop: async (storage, url, src, callback) => {
      callback({
        type: 'image/png',
        data: (await storage.get(key))[key],
        encoding: 'base64-data-url'
      });
    }
  })
}

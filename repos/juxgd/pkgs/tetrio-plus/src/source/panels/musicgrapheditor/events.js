import { fetchAtlas } from '../../importers/sfx/decode.js';

export const events = [
  'node-end',
  'time-passed',
  'repeating-time-passed',
  'random-target',
  'parent-node-destroyed',
  'video-background-seeked',

  'fx-countdown',
  'fx-zen-levelup',
  'fx-master-levelup',
  'fx-100-players-left',
  'fx-30-players-left',
  'fx-10-players-left',
  'fx-60-seconds-left',
  'fx-30-seconds-left',
  'board-gone',
];

export const fxHasPlayerEnemyVariants = [
  'board-new',
  'board-height',
  'fx-line-clear',
  'fx-combo',
  'fx-offense',
  'fx-defense',
  'fx-any-spin',
  'fx-t-spin',
  'fx-o-spin',
  'fx-i-spin',
  'fx-j-spin',
  'fx-l-spin',
  'fx-s-spin',
  'fx-z-spin',
];
for (let sfx of fxHasPlayerEnemyVariants)
  events.push(sfx); // -player/-enemy have extra UI


[
  "home",
  "play1p",
  "playmulti",
  "about",
  "multilisting",
  "lobby",
  "victory",
  "multilog",
  "endleague",
  "league",
  "40l",
  "blitz",
  "zen",
  "custom",
  "results",
  "tetra",
  "tetra_records",
  "tetra_me",
  "tetra_players",
  "config",
  "config_bgmtweak",
  "config_account",
  "config_account_orders",
  "config_electron"
].forEach(evt => {
  events.push(`menu-${evt}-open`);
  events.push(`menu-${evt}-close`);
});
['forfeit', 'retry', 'replay', 'spectate'].forEach(evt => {
  events.push(`hud-${evt}-open`);
  events.push(`hud-${evt}-close`);
});

// run this snippet in the sound effects editor to generate/update this:
// copy(app.sprites.map(sprite => `"${sprite.name}"`).join(', '))
let soundEffects = ["boardappear", "zenith_levelup_b", "combo_2_power", "mission", "mmstart", "combo_4_power", "s", "clearquad", "combo_7", "speed_tick_whirl", "speed_up_2", "allclear", "failure", "hold", "social_close_minor", "social_online", "b2bcharge_distance_1", "combo_16", "t", "clutch", "level10", "detonate2", "thunder6", "staffspam", "rsg", "protected_medium", "mission_free", "speed_tick_3", "combo_9", "card_tone_volatile", "damage_alert", "zenith_start", "combo_12_power", "damage_large", "i", "pause_start", "ratingraise", "boardlock_clear", "impact", "boardlock", "combo_3", "pause_continue", "garbagewindup_4", "card_tone_expert", "protected_large", "combo_6_power", "garbagewindup_1", "ranklower", "b2bcharge_blast_3", "ribbon_on", "combo_14", "b2bcharge_1", "spinend", "rsg_go", "offset", "card_tone_doublehole", "social_notify_major", "maintenance", "harddrop", "zenith_levelup_ahalfsharp", "level100", "spin", "combo_13_power", "gameover", "userleave", "combo_15_power", "menuback", "protected_small", "menuclick", "counter", "garbagewindup_2", "zenith_split_cleared", "se_vol_blip", "achievement_1", "zenith_levelup_a", "combo_9_power", "speed_tick_2", "social_notify_minor", "undo", "notify", "losestock", "victory", "clearline", "warning", "menuconfirm", "combo_13", "zenith_speedrun_start", "combo_10_power", "combo_1_power", "piece_change", "combo_2", "card_tone_invisible", "shatter", "card_tone_duo", "detonate1", "userjoin", "speed_tick_1", "achievement_2", "zenith_levelup_c", "supporter", "b2bcharge_distance_2", "combo_10", "l", "hyperalert", "garbagerise", "card_tone_gravity", "cutin_superlobby", "countdown4", "combo_5_power", "combo_11_power", "combo_8_power", "finessefault", "btb_break", "rotate", "social_invite", "queue_change", "garbage_out_large", "boardlock_clink", "combobreak", "boardlock_revive", "card_slide_1", "j", "garbage_in_large", "combo_6", "social_close", "combo_14_power", "mission_versus", "b2bcharge_blast_1", "zenith_speedrun_end", "finish", "garbagewindup_3", "speed_down", "social_offline", "menuhit2", "no", "zenith_levelup_fsharp", "combo_5", "btb_3", "purchase_start", "zenith_levelup_e", "detonated", "target", "pause_retry", "worldrecord", "countdown1", "elim", "menuhover", "timer2", "move", "b2bcharge_blast_2", "card_slide_2", "ribbon_tap", "countdown5", "b2bcharge_4", "damage_medium", "thunder1", "social_open_minor", "matchintro", "btb_1", "level1", "pause_exit", "combo_3_power", "o", "levelup", "ribbon_off", "redo", "b2bcharge_3", "clearbtb", "map_change", "wound_repel", "timer1", "thunder3", "card_slide_4", "speed_tick_4", "card_tone_messy", "combo_7_power", "countdown3", "social_open", "bombdetonate", "combo_1", "softdrop", "menutap", "personalbest", "level500", "hit", "speed_up_4", "combo_12", "rankraise", "wound", "garbagesmash", "card_slide_3", "b2bcharge_distance_3", "showscore", "party_ready", "achievement_3", "b2bcharge_danger", "clearspin", "card_select", "b2bcharge_start", "boardlock_fail", "garbage_in_medium", "exchange", "scoreslide_in", "mission_league", "garbage_in_small", "garbage_out_small", "applause", "social_dm", "thunder5", "combo_4", "topout", "speed_up_1", "sidehit", "menuhit3", "damage_small", "speed_up_3", "staffsilence", "ratinglower", "btb_2", "staffwarning", "scoreslide_out", "b2bcharge_blast_4", "ribbon", "card_tone_allspin", "combo_8", "card_tone_nohold", "fire", "floor", "garbage_out_medium", "combo_11", "thunder2", "thunder4", "countdown2", "z", "combo_16_power", "zenith_split_missed", "menuhit1", "death", "warp", "combo_15", "go", "b2bcharge_2"];

let div = document.createElement('div');
try {
  div.innerHTML = `fetching sfx atlas... <button>skip and use hardcoded sound effects</button>`;
  document.body.appendChild(div);
  
  let controller = new AbortController();
  div.querySelector('button').addEventListener('click', () => controller.abort());
  
  let fetch = await fetchAtlas(controller);
  
  soundEffects = Object.keys(fetch).sort((a,b) => {
    [a,b] = [a,b].map(x => x.replace(/\d+/g, m => m.padStart(4, '0')));
    let a_c = /^combo_\d+$/.test(a);
    let a_p = /^combo_\d+_power$/.test(a);
    let b_c = /^combo_\d+$/.test(b);
    let b_p = /^combo_\d+_power$/.test(b);
    if (a_c && b_p) return -1;
    if (a_p && b_c) return 1;
    return a > b ? 1 : -1;
  });
} catch(ex) {
  console.warn("failed to fetch sound effects atlas, falling back to hardcoded values", ex);
} finally {
  div.remove();
}
for (let sfx of soundEffects)
  events.push('sfx-' + sfx);

// Events that use the 'predicateExpression' field and their labels
export const eventValueExtendedModes = {
  'board-height-player': 'Rows high',
  'board-height-enemy': 'Rows high',
  'fx-countdown': 'Count',
  'fx-line-clear-player': 'Lines cleared',
  'fx-line-clear-enemy': 'Lines cleared',
  'fx-offense-player': 'Lines sent',
  'fx-offense-enemy': 'Lines sent',
  'fx-defense-player': 'Lines blocked',
  'fx-defense-enemy': 'Lines blocked',
  'fx-combo-player': 'Combo',
  'fx-combo-enemy': 'Combo'
}

export const eventHasTarget = {
  'fork': true,
  'goto': true,
  'kill': false,
  'random': false,
  'dispatch': false,
  'create': false,
  'set': false
};

let eventSet = new Set(events);
export function eventType(event) {
  if (event.startsWith('sfx-')) {
    let match = /^sfx-(\w+)(?:-(\w+))?/.exec(event);
    if (match) {
      let [_, event, scope] = match;
      if (eventSet.has('sfx-' + event))
        return { mode: 'sfx', event: 'sfx-' + event, scope: scope || '' };
    }
  }

  let fx = /^(fx-.+?|board-(?:height|new|gone))(?:-(player|enemy))?$/.exec(event);
  if (fx && fxHasPlayerEnemyVariants.includes(fx[1])) {
    let scope = fx[2] || '';
    if (eventSet.has(fx[1]))
      return { mode: 'fx', event: fx[1], scope }
  }

  if (!eventSet.has(event))
    return { mode: 'custom', event: 'CUSTOM' };

  return { mode: 'normal', event }
};

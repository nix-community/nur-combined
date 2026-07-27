/* vdemeester personal ergodox layout  */
#include QMK_KEYBOARD_H
#include "led.h"
#include "action_layer.h"
#include "action_util.h"
#include "eeconfig.h"
#include "keymap_bepo.h"

/* Layers */
enum {
  BASE = 0,
  NMDIA,
  FNLR,
  GAME,
};

/* Macros */
enum {
  MDBL0 = 0,

  MFNLR,

  // Cut/Copy/Paste
  MCUT,
  MCOPY,
  MPSTE
};

/* Fn keys */
enum {
  F_BSE = 0,
  F_NMEDIA,
  F_SFT,
  F_ALT,
  F_CTRL,
  F_GAME
};

/* States & timers */
uint16_t kf_timers[12];

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
  /* Basic layer
   *
   * ,--------------------------------------------------.            ,---------------------------------------------------.
   * |   `    | 1/F1 | 2/F2 | 3/F3 | 4/F4  | 5/F5 | F11/Ins  |       | F12/%| 6/F6 | 7/F7 | 8/F8 | 9/F9 | 0/F10 |    -   |
   * |--------+------+------+------+-------+-------------|           |------+------+------+------+------+-------+--------|
   * | Tab    |   Q  |   W  |   E  |   R   |   T  |Backsp|           |Backsp|   Y  |   U  |   I  |   O  |   P   |    =   |
   * |--------+------+------+------+-------+------|ace   |           |ace   |------+------+------+------+-------+--------|
   * |   Fn   |   A  |   S  |   D  |   F   |   G  |------|           |------|   H  |   J  |   K  |   L  |   ;   | '/Shift|
   * |--------+------+------+------+-------+------|Enter |           |Enter |------+------+------+------+-------+--------|
   * | LShift |   Z  |   X  |   C  |   V   |   B  |      |           |      |   N  |   M  |   ,  |   .  |   /   | \/Shift|
   * `--------+------+------+------+-------+-------------'           `-------------+------+------+------+-------+--------'
   *   | MUTE |  V+  |  V-  | LGui | A/ESC |                                       | RAlt | MENU |  L3  |       |        |
   *   `-----------------------------------'                                       `-------------------------------------'
   *                                       ,--------------.       ,-------------.
   *                                       |  Del  | PgUp |       | PgUp |  Del |
   *                                ,------+-------+------|       |------+------+------.
   *                                |      |       | PgDn |       | PgDn |      |      |
   *                                |Space | LShft |------|       |------|RShift|Enter |
   *                                |      |       | Ctl  |       |  Ctl |      |      |
   *                                `---------------------'       `--------------------'
   */
  // If it accepts an argument (i.e, is a function), it doesn't need KC_.
  // Otherwise, it needs KC_*
  [BASE] = LAYOUT_ergodox(  // layer 0 : default
                  // left hand
		  KC_GRV, KC_1, KC_2, KC_3, KC_4, KC_5, KC_INSERT,
                  KC_TAB,       KC_Q,      KC_W,      KC_E,           KC_R,     KC_T,   KC_BSPC,
                  F(F_NMEDIA),     KC_A,      KC_S,      KC_D,           KC_F,     KC_G,
                  SFT_T(KC_BSLASH),      KC_Z,      KC_X,      KC_C,           KC_V,     KC_B,    KC_ENT,
                  KC_MUTE,  KC_VOLU,    KC_VOLD,  KC_LGUI,  ALT_T(KC_ESC),

                  KC_DELT,  KC_PGUP,
                  KC_PGDN,
                  KC_SPC,    KC_LSHIFT,  KC_LCTL,

                  // right hand
		  KC_EQUAL, KC_6, KC_7, KC_8, KC_9, KC_0, KC_MINS,
                  KC_BSPC,     KC_Y,   KC_U,    KC_I,    KC_O,    KC_P,     KC_LBRACKET,
                  KC_H,   KC_J,    KC_K,    KC_L,    KC_SCLN,  SFT_T(KC_QUOT),
                  KC_ENT,      KC_N,   KC_M,    KC_COMM, KC_DOT,  KC_SLSH,  KC_RBRACKET,
                  KC_RALT, KC_APP, F(F_GAME), KC_UNDEFINED,   KC_UNDEFINED,

                  KC_PGUP, KC_DELT,
                  KC_PGDN,
                  KC_RCTL, F(F_SFT),  KC_ENT
                    ),
  /* Navigation and media layer
   *
   * ,--------------------------------------------------.           ,--------------------------------------------------.
   * |        |  F1  |  F2  |  F3  |  F4  |  F5  |  F6  |           |  F7  |  F8  |  F9  |  F10 |  F11 |  F12 |        |
   * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
   * |        |      |      | MsUp |      | WHUP | Vol+ |           | Lclk |      | Home |  Up  | End  |      |        |
   * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
   * |        |      | MsLe | MsDo | MsRi | WHD  |------|           |------|      | Left | Down | Right|      |        |
   * |--------+------+------+------+------+------| Vol- |           | Rclk |------+------+------+------+------+--------|
   * |        |      |      |      |      |      |      |           |      |      |      |      |      |      |        |
   * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
   *   |      |      |      |      |      |                                       |      |      |      |      |      |
   *   `----------------------------------'                                       `----------------------------------'
   *                                        ,-------------.       ,-------------.
   *                                        | Mute |      |       |      | Caps |
   *                                 ,------|------|------|       |------+------+------.
   *                                 |      |      |      |       |      |      |      |
   *                                 | Prev | Next |------|       |------| LEAD | Play |
   *                                 |      |      |      |       |      |      |      |
   *                                 `--------------------'       `--------------------'
   */
  // SYMBOLS
  [NMDIA] = LAYOUT_ergodox(
                   // left hand
                   KC_UNDEFINED,  KC_F1,         KC_F2,         KC_F3,         KC_F4,         KC_F5,         KC_F6,
                   KC_UNDEFINED,  KC_UNDEFINED,  KC_UNDEFINED,  KC_MS_U,       KC_UNDEFINED,  KC_WH_U,  KC_VOLU,
                   KC_TRNS,       KC_UNDEFINED,  KC_MS_L,       KC_MS_D,       KC_MS_R,       KC_WH_D,
                   KC_UNDEFINED,  KC_UNDEFINED,  KC_UNDEFINED,  KC_UNDEFINED,  KC_UNDEFINED,  KC_UNDEFINED,  KC_VOLD,
                   KC_TRNS,       KC_TRNS,       KC_UNDEFINED,  KC_TRNS,       KC_TRNS,
                   KC_MUTE,  KC_LEAD,
                   KC_TRNS,
                   KC_MPRV,  KC_MNXT,  KC_TRNS,
                   // right hand
                   KC_F7,        KC_F8,          KC_F9,          KC_F10,          KC_F11,          KC_F12,       KC_UNDEFINED,
                   KC_BTN1, KC_UNDEFINED,   KC_HOME,        KC_UP,           KC_END,          KC_PGUP, KC_UNDEFINED,
                   KC_UNDEFINED,   KC_LEFT,        KC_DOWN,         KC_RIGHT,        KC_PGDN, KC_UNDEFINED,
                   KC_BTN2, KC_UNDEFINED,   RGB_TOG,   RGB_MOD,    RGB_HUI,    RGB_HUD, KC_UNDEFINED,
                   RGB_SAI,   RGB_SAD,   RGB_SAD,    RGB_VAI,    RGB_VAD,
                   KC_TRNS, KC_CAPS,
                   KC_TRNS,
                   KC_TRNS, KC_TRNS,   KC_MPLY
                   ),
  /* fn layer
   *
   * ,--------------------------------------------------.           ,--------------------------------------------------.
   * |        |      |      |      |      |      |Insert|           |Insert|Eject |Power |Sleep | Wake |PrtScr|ScrollLk|
   * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
   * |        |      |      |      |      |      |VolUp |           |      |      |      | MsUp |      | PgUp | Pause  |
   * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
   * |        |      |      | Calc | Mail |Browsr|------|           |------|      |MsLeft|MsDown|MsRght| PgDn |        |
   * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
   * |        |      | cut  | copy |paste | Mute |VolDn |           |      |      |      |      |      |      |        |
   * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
   *   |      |      |      |      |      |                                       | Lclk | Mclk | Rclk |      |      |
   *   `----------------------------------'                                       `----------------------------------'
   *                                        ,-------------.       ,-------------.
   *                                        |      |      |       |      |      |
   *                                 ,------|------|------|       |------+------+------.
   *                                 |      |      |      |       | Next |      |      |
   *                                 | Mute |      |------|       |------|      |      |
   *                                 |      |      |      |       | Prev |      |      |
   *                                 `--------------------'       `--------------------'
   */
  // MEDIA AND MOUSE
  [FNLR] = LAYOUT_ergodox(
                  KC_TRNS, KC_TRNS, KC_TRNS,      KC_TRNS,     KC_TRNS,      KC_TRNS, KC_INS,
                  KC_TRNS, KC_TRNS, KC_TRNS,      KC_TRNS,     KC_TRNS,      KC_TRNS, KC_VOLU,
                  KC_TRNS, KC_TRNS, KC_TRNS,      KC_CALC,     KC_MAIL,      KC_WHOM,
                  KC_TRNS, KC_TRNS, M(MCUT),      M(MCOPY),    M(MPSTE),     KC_MUTE, KC_VOLD,
                  KC_TRNS, KC_TRNS, KC_TRNS,      KC_TRNS,     KC_TRNS,

                  KC_TRNS, KC_TRNS,
                  KC_TRNS,
                  KC_MUTE, KC_TRNS, KC_TRNS,
                  // right hand
                  KC_INS,   KC_EJCT, KC_PWR,  KC_SLEP, KC_WAKE, KC_PSCR, KC_SLCK,
                  KC_TRNS,  KC_TRNS, KC_TRNS, KC_MS_U, KC_TRNS, KC_TRNS, KC_PAUS,
                  KC_TRNS, KC_MS_L, KC_MS_D, KC_MS_R, KC_TRNS, KC_TRNS,
                  KC_TRNS,  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
                  KC_BTN1, KC_BTN2, KC_BTN3, KC_TRNS, KC_TRNS,

                  KC_TRNS, KC_TRNS,
                  KC_BTN4,
                  KC_BTN5, KC_MPRV, KC_MNXT
                  ),

  /* Keymap 3: Gaming
   *
   * ,--------------------------------------------------.           ,--------------------------------------------------.
   * |   #    |   "  |   «  |   »  |   (  |   )  | INS  |           |      |      |      |      |      |      |        |
   * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
   * |  TAB   |   1  |  2   | UP   |  3   |  4   |Back  |           |      |      |      |      |      |      |        |
   * |--------+------+------+------+------+------|Space |           |      |------+------+------+------+------+--------|
   * |   A    |   5  | LEFT | DOWN | RIGHT|  6   |------|           |------|      |      |      |      |      |        |
   * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
   * |   B    |   7  |  8   |   9  |  0   |  C   |Enter |           |      |      |      |      |      |      |        |
   * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
   *   | MUTE |  V+  |  V-  | GUI  | LAlt |                                       |      |  L0  |      |      |      |
   *   `----------------------------------'                                       `----------------------------------'
   *                                        ,-------------.       ,-------------.
   *                                        | DEL  | GUI  |       |      |      |
   *                                 ,------|------|------|       |------+------+------.
   *                                 |      |      | LAlt |       |      |      |      |
   *                                 | Space|LShift|------|       |------|      |      |
   *                                 |      |      |ctr/Es|       |      |      |      |
   *                                 `--------------------'       `--------------------'
   */
  [GAME] = LAYOUT_ergodox(
                  // left hand
                  BP_DOLLAR,    BP_DOUBLE_QUOTE,     BP_LEFT_GUILLEMET,   BP_RIGHT_GUILLEMET,   BP_LEFT_PAREN,    BP_RIGHT_PAREN,   KC_INSERT,
                  KC_TAB,       KC_KP_1,             KC_KP_2,             KC_UP,                KC_KP_3,          KC_KP_4,          KC_BSPC,
                  BP_A,         KC_KP_5,             KC_LEFT,             KC_DOWN,              KC_RIGHT,         KC_KP_6,
                  BP_B,         KC_KP_7,             KC_KP_8,             KC_KP_9,              KC_KP_0,          BP_C,             KC_ENT,
                  KC_MUTE,      KC_VOLU,             KC_VOLD,             KC_LGUI,              ALT_T(KC_ESC),
                  KC_DELETE,        KC_RGUI,
                  KC_LALT,
                  KC_SPC,           KC_LSHIFT,        KC_LCTL,
                  // right hand
                  KC_UNDEFINED, KC_UNDEFINED,        KC_UNDEFINED,        KC_UNDEFINED,         KC_UNDEFINED,     KC_UNDEFINED,     KC_UNDEFINED,
                  KC_UNDEFINED, KC_UNDEFINED,        KC_UNDEFINED,        KC_UNDEFINED,         KC_UNDEFINED,     KC_UNDEFINED,     KC_UNDEFINED,
                  KC_UNDEFINED,        KC_UNDEFINED,        KC_UNDEFINED,         KC_UNDEFINED,     KC_UNDEFINED,     KC_UNDEFINED,
                  KC_UNDEFINED, KC_UNDEFINED,        KC_UNDEFINED,        KC_UNDEFINED,         KC_UNDEFINED,     KC_UNDEFINED,     KC_UNDEFINED,
                  KC_UNDEFINED,        KC_UNDEFINED,              KC_TRNS,     KC_UNDEFINED,     KC_UNDEFINED,
                  KC_UNDEFINED, KC_UNDEFINED,
                  KC_UNDEFINED,
                  KC_UNDEFINED, KC_UNDEFINED,        KC_UNDEFINED
                  ),
};

const uint16_t PROGMEM fn_actions[] = {
  [F_BSE]    = ACTION_LAYER_CLEAR(ON_PRESS),
  [F_NMEDIA] = ACTION_LAYER_TAP_TOGGLE(NMDIA),
  [F_GAME]   = ACTION_LAYER_TAP_TOGGLE(GAME),
  [F_SFT]    = ACTION_MODS_ONESHOT (MOD_LSFT),
  [F_ALT]    = ACTION_MODS_ONESHOT (MOD_LALT),
  [F_CTRL]   = ACTION_MODS_ONESHOT (MOD_LCTL)
};

LEADER_EXTERNS();

const macro_t *action_get_macro(keyrecord_t *record, uint8_t id, uint8_t opt)
{
  // MACRODOWN only works in this function
  switch(id) {
  case MDBL0:
    if (record->event.pressed) {
      return MACRO( I(25), T(P0), T(P0), END );
    }
    break;
  case MFNLR:
    // Activate 2 layers at once
    // layer_state ^= (1 << NUMR) | (1 << FNLR);
    layer_state ^= (1 << FNLR);
    break;
  case MCUT:
    if (record->event.pressed) {
      return MACRO(D(LSFT), T(DELT), U(LSFT), END);
    }
    break;
  case MCOPY:
    if (record->event.pressed) {
      return MACRO(D(LCTL), T(INS), U(LCTL), END);
    }
    break;
  case MPSTE:
    if (record->event.pressed) {
      return MACRO(D(LSFT), T(INS), U(LSFT), END);
    }
    break;
  }
  return MACRO_NONE;
};

// Runs just one time when the keyboard initializes.
void matrix_init_user(void) {

};

void tap (uint16_t codes[]) {
  for (int i = 0; codes[i] != 0; i++) {
    register_code (codes[i]);
    unregister_code (codes[i]);
    wait_ms (50);
  }
}

void do_unicode (void) {
  register_code (KC_RCTL);
  register_code (KC_RSFT);
  register_code (KC_U);
  unregister_code (KC_U);
  unregister_code (KC_RSFT);
  unregister_code (KC_RCTL);
  wait_ms (100);
}

// Runs constantly in the background, in a loop.
void matrix_scan_user(void) {

  uint8_t layer = biton32(layer_state);

  ergodox_board_led_on();
  ergodox_right_led_1_off();
  ergodox_right_led_2_off();
  ergodox_right_led_3_off();

  ergodox_right_led_1_set (LED_BRIGHTNESS_LO);
  ergodox_right_led_2_set (LED_BRIGHTNESS_LO);
  ergodox_right_led_3_set (LED_BRIGHTNESS_LO);

  // led 3: caps lock
  if (host_keyboard_leds() & (1<<USB_LED_CAPS_LOCK)) {
    ergodox_right_led_1_on();
  }
  switch (layer) {
  case NMDIA:
    ergodox_right_led_2_on();
    break;
  case GAME:
    ergodox_right_led_3_on();
    break;
    //case NUMR:
    //ergodox_right_led_3_on();
    //break;
  default:
    // none
    break;
  }


  LEADER_DICTIONARY() {
    leading = false;
    leader_end ();

    SEQ_ONE_KEY (KC_U) {
      do_unicode();
    }

    SEQ_ONE_KEY (BP_Y) {
      uint16_t codes[] = {BP_O, BP_SLSH, 0};
      tap (codes);
    }

  }
  /* // led 1: numeric layer */
  /* if (layer_state & (1 << NUMR)) { */
  /*     ergodox_right_led_2_on(); */
  /* } */
  /* // led 2: FNLR */
  /* if (default_layer_state == 1 << FNLR) { */
  /*     ergodox_right_led_1_on(); */
  /* } */

};

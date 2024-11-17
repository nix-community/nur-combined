#include QMK_KEYBOARD_H
#include "version.h"

// ## QMK reference:
// ### compound key codes:
// C(kc) LCTL(kc)  -> send Ctrl event then kc
// S(kc) LSFT(kc)  -> send Shift event then kc
// A(kc) LALT(kc)  -> send Alt event then kc
// G(kc) LGUI(kc)  -> send Gui event then kc
// - chain these, e.g. C(A(KC_DEL)) to send Ctrl + Alt + Delete
// - source: <repo:qmk/qmk_firmware:doc/feature_advanced_keycodes.md>
// ### layer navigation
// MO(ly)          -> activate the layer for as long as this key remains pressed
// LM(ly,mod)      -> activate the layer, and the given modifier, while key remains pressed
// LT(ly,kc)       -> like MO, but also send `kc` upon press
// OSL(ly)         -> activate the layer, until the next key is pressed (one shot)
// TG(ly)          -> activate the layer, until this key is tapped again
// - source: <repo:qmk/qmk_firmware:doc/feature_layers.md>

enum layers {
    BASE,  // default layer
    SYMB,  // symbols
    MDIA,  // media keys
};

enum custom_keycodes {
    VRSN = SAFE_RANGE,
};

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
/* Keymap 0: Basic layer
 *
 * ,--------------------------------------------------.           ,--------------------------------------------------.
 * |   Grv  |   1  |   2  |   3  |   4  |   5  | LEFT |           | RIGHT|   6  |   7  |   8  |   9  |   0  |   -    |
 * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
 * | Del    |   Q  |   W  |   E  |   R  |   T  |  L1  |           |  L1  |   Y  |   U  |   I  |   O  |   P  |   \    |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * | Esc    |   A  |   S  |   D  |   F  |   G  |------|           |------|   H  |   J  |   K  |   L  |  ;   |    '   |
 * |--------+------+------+------+------+------| GUI  |           |      |------+------+------+------+------+--------|
 * | LShift |  Z   |   X  |   C  |   V  |   B  |      |           |      |   N  |   M  |   ,  |   .  |  /   |   =    |
 * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   |Ctrl  |  L1  |  L2  | Left | Right|                                       |  Up  | Down |   [  |   ]  | Gui  |
 *   `----------------------------------'                                       `----------------------------------'
 *                                      ,-------------.           ,-------------.
 *                                      | Left | Right|           | Left | Right|
 *                               ,------|------|------|           |------+------+------.
 *                               |      |      | L1   |           | PgUp |      |      |
 *                               | Space|Backsp|------|           |------|  Tab |Enter |
 *                               |      |ace   | L1   |           | PgDn |      |      |
 *                               `--------------------'           `--------------------'
 */
[BASE] = LAYOUT_ergodox_pretty(
  // left hand
  KC_GRV,     KC_1,     KC_2,     KC_3,    KC_4,    KC_5,    KC_LEFT,              KC_RGHT,      KC_6,    KC_7,    KC_8,    KC_9,    KC_0,    KC_MINS,
  KC_DEL,     KC_Q,     KC_W,     KC_E,    KC_R,    KC_T,    MO(SYMB),             MO(SYMB),     KC_Y,    KC_U,    KC_I,    KC_O,    KC_P,    KC_BSLS,
  KC_ESC,     KC_A,     KC_S,     KC_D,    KC_F,    KC_G,                                        KC_H,    KC_J,    KC_K,    KC_L,    KC_SCLN, KC_QUOT,
  KC_LSFT,    KC_Z,     KC_X,     KC_C,    KC_V,    KC_B,    KC_LGUI,              KC_NO,        KC_N,    KC_M,    KC_COMM, KC_DOT,  KC_SLSH, KC_EQL,
  KC_LCTL,    MO(SYMB), TG(MDIA), KC_LEFT, KC_RGHT,                                                       KC_UP,   KC_DOWN, KC_LBRC, KC_RBRC, KC_RGUI,
                                                    KC_LEFT, KC_RGHT,              KC_LEFT,      KC_RGHT,
                                                             MO(SYMB),             KC_PGUP,
                                           KC_SPC,  KC_BSPC, MO(SYMB),             KC_PGDN,      KC_TAB,  KC_ENT
),
/* Keymap 1: Symbol Layer
 *
 * ,---------------------------------------------------.           ,--------------------------------------------------.
 * |         |      |      |      |      |      |      |           |      |      |      |      |   [  |   ]  |        |
 * |---------+------+------+------+------+------+------|           |------+------+------+------+------+------+--------|
 * |         |   !  |   @  |   {  |   }  |   |  |      |           |      |   Up |      |      |   {  |   }  |        |
 * |---------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |         |   #  |   $  |   (  |   )  |   `  |------|           |------| Down |      |      |      |      |        |
 * |---------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |         |   %  |   ^  |   [  |   ]  |   ~  |      |           |      |   &  |      |      |      |      |        |
 * `---------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   | EPRM  |      |      |      |      |                                       |      |      |      |      |      |
 *   `-----------------------------------'                                       `----------------------------------'
 *                                        ,-------------.       ,-------------.
 *                                        |Animat|      |       |Toggle|Solid |
 *                                 ,------|------|------|       |------+------+------.
 *                                 |Bright|Bright|      |       |      |Hue-  |Hue+  |
 *                                 |ness- |ness+ |------|       |------|      |      |
 *                                 |      |      |      |       |      |      |      |
 *                                 `--------------------'       `--------------------'
 */
[SYMB] = LAYOUT_ergodox_pretty(
  // left hand
  VRSN,    KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_LBRC, KC_RBRC, KC_TRNS,
  KC_TRNS, KC_EXLM, KC_AT,   KC_LCBR, KC_RCBR, KC_PIPE, KC_TRNS,     KC_TRNS, KC_UP,   KC_TRNS, KC_TRNS, KC_LCBR, KC_RCBR, KC_TRNS,
  KC_TRNS, KC_HASH, KC_DLR,  KC_LPRN, KC_RPRN, KC_GRV,                        KC_DOWN, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
  KC_TRNS, KC_PERC, KC_CIRC, KC_LBRC, KC_RBRC, KC_TILD, KC_TRNS,     KC_TRNS, KC_AMPR, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
  EE_CLR,  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,                                         KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,
                                               RGB_MOD, KC_TRNS,     RGB_TOG, RGB_M_P,
                                                        KC_TRNS,     KC_TRNS,
                                      RGB_VAD, RGB_VAI, KC_TRNS,     KC_TRNS, RGB_HUD, RGB_HUI
),
/* Keymap 2: Media and mouse keys
 *
 * ,--------------------------------------------------.           ,--------------------------------------------------.
 * |Version |  F1  |  F2  |  F3  |  F4  |  F5  |      |           |      |  F6  |  F7  |  F8  |  F9  |  F10 |   F11  |
 * |--------+------+------+------+------+-------------|           |------+------+------+------+------+------+--------|
 * |        |      |      | MsUp |      |      |      |           |      |      |      |      |      |      |   F12  |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |        |      |MsLeft|MsDown|MsRght|      |------|           |------|      |      |      |      |      |  Play  |
 * |--------+------+------+------+------+------|      |           |      |------+------+------+------+------+--------|
 * |        |      |      |      |      |      |      |           |      |      |      | Prev | Next |      |        |
 * `--------+------+------+------+------+-------------'           `-------------+------+------+------+------+--------'
 *   |      |      |      | Lclk | Rclk |                                       |VolUp |VolDn | Mute |      |      |
 *   `----------------------------------'                                       `----------------------------------'
 *                                        ,-------------.       ,-------------.
 *                                        |      |      |       |      |      |
 *                                 ,------|------|------|       |------+------+------.
 *                                 |      |      |      |       |      |      |Brwser|
 *                                 |      |      |------|       |------|      |Back  |
 *                                 |      |      |      |       |      |      |      |
 *                                 `--------------------'       `--------------------'
 */
[MDIA] = LAYOUT_ergodox_pretty(
  // left hand
  VRSN,    KC_F1,   KC_F2,   KC_F3,   KC_F4,   KC_F5,   KC_TRNS,     KC_TRNS, KC_F6,   KC_F7,   KC_F8,   KC_F9,   KC_F10,  KC_F11,
  KC_TRNS, KC_TRNS, KC_TRNS, KC_MS_U, KC_TRNS, KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_F12,
  KC_TRNS, KC_TRNS, KC_MS_L, KC_MS_D, KC_MS_R, KC_TRNS,                       KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_MPLY,
  KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS, KC_TRNS, KC_MPRV, KC_MNXT, KC_TRNS, KC_TRNS,
  KC_TRNS, KC_TRNS, KC_TRNS, KC_BTN1, KC_BTN2,                                         KC_VOLU, KC_VOLD, KC_MUTE, KC_TRNS, KC_TRNS,

                                               KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS,
                                                        KC_TRNS,     KC_TRNS,
                                      KC_TRNS, KC_TRNS, KC_TRNS,     KC_TRNS, KC_TRNS, KC_WBAK
),
};
// clang-format on

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    if (record->event.pressed) {
        switch (keycode) {
            case VRSN:
                SEND_STRING(QMK_KEYBOARD "/" QMK_KEYMAP " @ " QMK_VERSION);
                return false;
        }
    }
    return true;
}

// Runs just one time when the keyboard initializes.
void keyboard_post_init_user(void) {
#ifdef RGBLIGHT_COLOR_LAYER_0
    rgblight_setrgb(RGBLIGHT_COLOR_LAYER_0);
#endif
};

// Runs whenever there is a layer state change.
layer_state_t layer_state_set_user(layer_state_t state) {
    ergodox_board_led_off();
    ergodox_right_led_1_off();
    ergodox_right_led_2_off();
    ergodox_right_led_3_off();

    uint8_t layer = get_highest_layer(state);
    switch (layer) {
        case 0:
#ifdef RGBLIGHT_COLOR_LAYER_0
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_0);
#endif
            break;
        case 1:
            ergodox_right_led_1_on();
#ifdef RGBLIGHT_COLOR_LAYER_1
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_1);
#endif
            break;
        case 2:
            ergodox_right_led_2_on();
#ifdef RGBLIGHT_COLOR_LAYER_2
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_2);
#endif
            break;
        case 3:
            ergodox_right_led_3_on();
#ifdef RGBLIGHT_COLOR_LAYER_3
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_3);
#endif
            break;
        case 4:
            ergodox_right_led_1_on();
            ergodox_right_led_2_on();
#ifdef RGBLIGHT_COLOR_LAYER_4
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_4);
#endif
            break;
        case 5:
            ergodox_right_led_1_on();
            ergodox_right_led_3_on();
#ifdef RGBLIGHT_COLOR_LAYER_5
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_5);
#endif
            break;
        case 6:
            ergodox_right_led_2_on();
            ergodox_right_led_3_on();
#ifdef RGBLIGHT_COLOR_LAYER_6
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_6);
#endif
            break;
        case 7:
            ergodox_right_led_1_on();
            ergodox_right_led_2_on();
            ergodox_right_led_3_on();
#ifdef RGBLIGHT_COLOR_LAYER_7
            rgblight_setrgb(RGBLIGHT_COLOR_LAYER_7);
#endif
            break;
        default:
            break;
    }

    return state;
};

bool rgb_matrix_indicators_advanced_user(uint8_t led_min, uint8_t led_max) {
    if (rgb_matrix_get_mode() != RGB_MATRIX_SOLID_COLOR) {
        // don't update the colors if some animation is running
        return false;
    }
    // predefined colors:
    // RGB_AZURE
    // RGB_BLACK
    // RGB_BLUE
    // RGB_CHARTREUSE
    // RGB_CORAL
    // RGB_CYAN
    // RGB_GOLD
    // RGB_GOLDENROD
    // RGB_GREEN
    // RGB_MAGENTA
    // RGB_ORANGE
    // RGB_PINK
    // RGB_PURPLE
    // RGB_RED
    // RGB_SPRINGGREEN
    // RGB_TEAL
    // RGB_TURQUOISE
    // RGB_WHITE
    // RGB_YELLOW
    for (uint8_t i = led_min; i <= led_max; i++) {
        switch (i) {
            // RIGHT SPLIT:
            // row 1
            case 0:
            case 1:
            case 2:
            case 3:
            case 4:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 2
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 3
            case 10:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            case 11:
            case 12:
            case 13:
                rgb_matrix_set_color(i, RGB_SPRINGGREEN);
                break;
            case 14:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 4
            case 15:
            case 16:
            case 17:
            case 18:
            case 19:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 5
            case 20:
            case 21:
            case 22:
            case 23:
                rgb_matrix_set_color(i, RGB_PINK);
                break;

            // LEFT SPLIT:
            // row 1
            case 24:
            case 25:
            case 26:
            case 27:
            case 28:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 2
            case 29:
            case 30:
            case 31:
            case 32:
            case 33:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 3
            case 34:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            case 35:
            case 36:
            case 37:
                rgb_matrix_set_color(i, RGB_SPRINGGREEN);
                break;
            case 38:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 4
            case 39:
            case 40:
            case 41:
            case 42:
            case 43:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
            // row 5
            case 44:
            case 45:
            case 46:
            case 47:
                rgb_matrix_set_color(i, RGB_PINK);
                break;
        }
    }
    return true;
}

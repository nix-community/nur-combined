<script setup>
import { ref } from 'vue'
import PlatformLayout from '../../PlatformLayout.vue'
import Checkbox from "../../Checkbox.vue";
import Expander from "../../Expander.vue";
import SelectField from "../../SelectField.vue";
import TextField from "../../TextField.vue";

const props = defineProps([
  'platform',
  'config'
])

const config = ref(props.config)
</script>

<template>
  <div id="input" class="md-settings-group">
    <!-- Enable Gamepad Input -->
    <Checkbox id="controller" locale-prefix="config" v-model="config.controller" default="true"></Checkbox>

    <!-- Emulated Gamepad Type -->
    <SelectField
      v-if="config.controller === 'enabled' && platform !== 'macos'"
      id="gamepad"
      :label="$t('config.gamepad')"
      :supporting="$t('config.gamepad_desc')"
      v-model="config.gamepad"
    >
      <option value="auto">{{ $t('_common.auto') }}</option>
      <PlatformLayout :platform="platform">
        <template #linux>
          <option value="ds5">{{ $t("config.gamepad_ds5") }}</option>
          <option value="switch">{{ $t("config.gamepad_switch") }}</option>
          <option value="xone">{{ $t("config.gamepad_xone") }}</option>
        </template>
        <template #windows>
          <option value="ds4">{{ $t('config.gamepad_ds4') }}</option>
          <option value="x360">{{ $t('config.gamepad_x360') }}</option>
        </template>
      </PlatformLayout>
    </SelectField>

    <!-- Additional options based on gamepad type -->
    <template v-if="config.controller === 'enabled'">
      <Expander
        v-if="config.gamepad === 'ds4' || config.gamepad === 'ds5' || (config.gamepad === 'auto' && platform !== 'macos')"
        icon="sports_esports"
        :title="$t(config.gamepad === 'ds4' ? 'config.gamepad_ds4_manual' : (config.gamepad === 'ds5' ? 'config.gamepad_ds5_manual' : 'config.gamepad_auto'))"
      >
        <div class="stack-sm">
          <!-- Automatic detection options (for Windows and Linux) -->
          <template v-if="config.gamepad === 'auto' && (platform === 'windows' || platform === 'linux')">
            <!-- Gamepad with motion-capability as DS4(Windows)/DS5(Linux) -->
            <Checkbox id="motion_as_ds4" locale-prefix="config" v-model="config.motion_as_ds4" default="true"></Checkbox>
            <!-- Gamepad with touch-capability as DS4(Windows)/DS5(Linux) -->
            <Checkbox id="touchpad_as_ds4" locale-prefix="config" v-model="config.touchpad_as_ds4" default="true"></Checkbox>
          </template>
          <!-- DS4 option: DS4 back button as touchpad click (on Automatic: Windows only) -->
          <template v-if="config.gamepad === 'ds4' || (config.gamepad === 'auto' && platform === 'windows')">
            <Checkbox id="ds4_back_as_touchpad_click" locale-prefix="config" v-model="config.ds4_back_as_touchpad_click" default="true"></Checkbox>
          </template>
          <!-- DS5 Option: Controller MAC randomization (on Automatic: Linux only) -->
          <template v-if="config.gamepad === 'ds5' || (config.gamepad === 'auto' && platform === 'linux')">
            <Checkbox id="ds5_inputtino_randomize_mac" locale-prefix="config" v-model="config.ds5_inputtino_randomize_mac" default="true"></Checkbox>
          </template>
        </div>
      </Expander>
    </template>

    <!-- Home/Guide Button Emulation Timeout -->
    <TextField
      v-if="config.controller === 'enabled'"
      id="back_button_timeout"
      placeholder="-1"
      :label="$t('config.back_button_timeout')"
      :supporting="$t('config.back_button_timeout_desc')"
      v-model="config.back_button_timeout"
    />

    <hr class="md-divider" />

    <!-- Enable Keyboard Input -->
    <Checkbox id="keyboard" locale-prefix="config" v-model="config.keyboard" default="true"></Checkbox>

    <!-- Key Repeat Delay-->
    <TextField
      v-if="config.keyboard === 'enabled' && platform === 'windows'"
      id="key_repeat_delay"
      placeholder="500"
      :label="$t('config.key_repeat_delay')"
      :supporting="$t('config.key_repeat_delay_desc')"
      v-model="config.key_repeat_delay"
    />

    <!-- Key Repeat Frequency-->
    <TextField
      v-if="config.keyboard === 'enabled' && platform === 'windows'"
      id="key_repeat_frequency"
      placeholder="24.9"
      :label="$t('config.key_repeat_frequency')"
      :supporting="$t('config.key_repeat_frequency_desc')"
      v-model="config.key_repeat_frequency"
    />

    <!-- Always send scancodes -->
    <Checkbox
      v-if="config.keyboard === 'enabled' && platform === 'windows'"
      id="always_send_scancodes"
      locale-prefix="config"
      v-model="config.always_send_scancodes"
      default="true"
    ></Checkbox>

    <!-- Mapping Key AltRight to Key Windows -->
    <Checkbox
      v-if="config.keyboard === 'enabled'"
      id="key_rightalt_to_key_win"
      locale-prefix="config"
      v-model="config.key_rightalt_to_key_win"
      default="false"
    ></Checkbox>

    <hr class="md-divider" />

    <!-- Enable Mouse Input -->
    <Checkbox id="mouse" locale-prefix="config" v-model="config.mouse" default="true"></Checkbox>

    <!-- High resolution scrolling support -->
    <Checkbox
      v-if="config.mouse === 'enabled'"
      id="high_resolution_scrolling"
      locale-prefix="config"
      v-model="config.high_resolution_scrolling"
      default="true"
    ></Checkbox>

    <!-- Native pen/touch support -->
    <Checkbox
      v-if="config.mouse === 'enabled'"
      id="native_pen_touch"
      locale-prefix="config"
      v-model="config.native_pen_touch"
      default="true"
    ></Checkbox>

    <hr class="md-divider" />

    <!-- Enable Input Only Mode -->
    <Checkbox id="enable_input_only_mode" locale-prefix="config" v-model="config.enable_input_only_mode" default="false"></Checkbox>

    <!-- Enable Rumble Messages to Controllers -->
    <template v-if="platform === 'windows'">
      <hr class="md-divider" />
      <Checkbox id="forward_rumble" locale-prefix="config" v-model="config.forward_rumble" default="true"></Checkbox>
    </template>
  </div>
</template>

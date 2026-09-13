<script setup>
import {ref, computed, inject} from 'vue'
import {$tp} from '../../platform-i18n'
import PlatformLayout from '../../PlatformLayout.vue'
import AdapterNameSelector from './audiovideo/AdapterNameSelector.vue'
import DisplayOutputSelector from './audiovideo/DisplayOutputSelector.vue'
import DisplayDeviceOptions from "./audiovideo/DisplayDeviceOptions.vue";
import DisplayModesSettings from "./audiovideo/DisplayModesSettings.vue";
import Banner from "../../Banner.vue";
import Checkbox from "../../Checkbox.vue";
import TextField from "../../TextField.vue";

const $t = inject('i18n').t;

const props = defineProps([
  'platform',
  'config',
  'vdisplay',
  'min_fps_factor',
])

const sudovdaStatus = {
  '1': 'Unknown',
  '0': 'Ready',
  '-1': 'Uninitialized',
  '-2': 'Version Incompatible',
  '-3': 'Watchdog Failed'
}

const currentDriverStatus = computed(() => sudovdaStatus[props.vdisplay])

const config = ref(props.config)

const validateFallbackMode = (event) => {
  const value = event.target.value;
  if (!value.match(/^\d+x\d+x\d+(\.\d+)?$/)) {
    event.target.setCustomValidity($t('config.fallback_mode_error'));
  } else {
    event.target.setCustomValidity('');
  }

  event.target.reportValidity();
}
</script>

<template>
  <div id="audio-video" class="md-settings-group">
    <!-- Audio Sink -->
    <TextField
      id="audio_sink"
      :label="$t('config.audio_sink')"
      :placeholder="$tp('config.audio_sink_placeholder', 'alsa_output.pci-0000_09_00.3.analog-stereo')"
      v-model="config.audio_sink"
    >
      <template #supporting>
        <span class="pre-wrap">{{ $tp('config.audio_sink_desc') }}</span>
        <PlatformLayout :platform="platform">
          <template #windows>
            <pre>tools\audio-info.exe</pre>
          </template>
          <template #linux>
            <pre>pacmd list-sinks | grep "name:"</pre>
            <pre>pactl info | grep Source</pre>
          </template>
          <template #macos>
            <a href="https://github.com/mattingalls/Soundflower" target="_blank">Soundflower</a><br>
            <a href="https://github.com/ExistentialAudio/BlackHole" target="_blank">BlackHole</a>.
          </template>
        </PlatformLayout>
      </template>
    </TextField>

    <PlatformLayout :platform="platform">
      <template #windows>
        <!-- Virtual Sink -->
        <TextField
          id="virtual_sink"
          :label="$t('config.virtual_sink')"
          :placeholder="$t('config.virtual_sink_placeholder')"
          v-model="config.virtual_sink"
        >
          <template #supporting><span class="pre-wrap">{{ $t('config.virtual_sink_desc') }}</span></template>
        </TextField>

        <!-- Install Steam Audio Drivers -->
        <Checkbox id="install_steam_audio_drivers" locale-prefix="config" v-model="config.install_steam_audio_drivers" default="true"></Checkbox>
        <Checkbox id="keep_sink_default" locale-prefix="config" v-model="config.keep_sink_default" default="true"></Checkbox>
        <Checkbox id="auto_capture_sink" locale-prefix="config" v-model="config.auto_capture_sink" default="true"></Checkbox>
      </template>
    </PlatformLayout>

    <!-- Disable Audio -->
    <Checkbox id="stream_audio" locale-prefix="config" v-model="config.stream_audio" default="true"></Checkbox>

    <AdapterNameSelector :platform="platform" :config="config" />
    <DisplayOutputSelector :platform="platform" :config="config" />
    <DisplayDeviceOptions :platform="platform" :config="config" />

    <!-- Display Modes -->
    <DisplayModesSettings :platform="platform" :config="config" />

    <!-- Fallback Display Mode -->
    <TextField
      id="fallback_mode"
      placeholder="1920x1080x60"
      :label="$t('config.fallback_mode')"
      :supporting="$t('config.fallback_mode_desc')"
      v-model="config.fallback_mode"
      @input="validateFallbackMode"
    />

    <template v-if="platform === 'windows'">
      <!-- Headless Mode -->
      <Checkbox id="headless_mode" locale-prefix="config" v-model="config.headless_mode" default="false"></Checkbox>
      <!-- Double Refreshrate -->
      <Checkbox id="double_refreshrate" locale-prefix="config" v-model="config.double_refreshrate" default="false"></Checkbox>
      <!-- Isolated Virtual Display -->
      <Checkbox id="isolated_virtual_display_option" locale-prefix="config" v-model="config.isolated_virtual_display_option" default="false"></Checkbox>

      <!-- SudoVDA Driver Status -->
      <Banner :variant="vdisplay ? 'warning' : 'success'">
        SudoVDA Driver status: {{currentDriverStatus}}
        <div class="md-body-small mt-1" v-if="vdisplay">
          Please ensure SudoVDA driver is installed to the latest version and enabled properly.
        </div>
      </Banner>
    </template>
  </div>
</template>

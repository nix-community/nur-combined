<script setup>
import { ref } from 'vue'
import { $tp } from '../../../platform-i18n'
import PlatformLayout from '../../../PlatformLayout.vue'
import TextField from '../../../TextField.vue'

const props = defineProps([
  'platform',
  'config'
])

const config = ref(props.config)
const outputNamePlaceholder = (props.platform === 'windows') ? '{de9bb7e2-186e-505b-9e93-f48793333810}' : '0'
</script>

<template>
  <TextField
    id="output_name"
    :label="$tp('config.output_name')"
    :placeholder="outputNamePlaceholder"
    v-model="config.output_name"
  >
    <template #supporting>
      {{ $tp('config.output_name_desc') }}
      <PlatformLayout :platform="platform">
        <template #windows>
          <pre>{
  "device_id": "{de9bb7e2-186e-505b-9e93-f48793333810}"
  "display_name": "\\\\.\\DISPLAY1"
  "friendly_name": "ROG PG279Q"
  ...
}</pre>
        </template>
        <template #linux>
          <pre>Info: Detecting displays
Info: Detected display: DVI-D-0 (id: 0) connected: false
Info: Detected display: HDMI-0 (id: 1) connected: true
Info: Detected display: DP-0 (id: 2) connected: true
Info: Detected display: DP-1 (id: 3) connected: false
Info: Detected display: DVI-D-1 (id: 4) connected: false</pre>
        </template>
        <template #macos>
          <pre>Info: Detecting displays
Info: Detected display: Monitor-0 (id: 3) connected: true
Info: Detected display: Monitor-1 (id: 2) connected: true</pre>
        </template>
      </PlatformLayout>
    </template>
  </TextField>
</template>

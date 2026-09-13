<script setup>
import { ref } from 'vue'
import Checkbox from "../../../Checkbox.vue";
import Expander from "../../../Expander.vue";
import SelectField from "../../../SelectField.vue";
import TextField from "../../../TextField.vue";

const props = defineProps([
  'platform',
  'config',
])

const config = ref(props.config)
</script>

<template>
  <div id="nvidia-nvenc-encoder" class="md-settings-group">
    <!-- Performance preset -->
    <SelectField
      id="nvenc_preset"
      :label="$t('config.nvenc_preset')"
      :supporting="$t('config.nvenc_preset_desc')"
      v-model="config.nvenc_preset"
    >
      <option value="1">P1 {{ $t('config.nvenc_preset_1') }}</option>
      <option value="2">P2</option>
      <option value="3">P3</option>
      <option value="4">P4</option>
      <option value="5">P5</option>
      <option value="6">P6</option>
      <option value="7">P7 {{ $t('config.nvenc_preset_7') }}</option>
    </SelectField>

    <!-- Two-pass mode -->
    <SelectField
      id="nvenc_twopass"
      :label="$t('config.nvenc_twopass')"
      :supporting="$t('config.nvenc_twopass_desc')"
      v-model="config.nvenc_twopass"
    >
      <option value="disabled">{{ $t('config.nvenc_twopass_disabled') }}</option>
      <option value="quarter_res">{{ $t('config.nvenc_twopass_quarter_res') }}</option>
      <option value="full_res">{{ $t('config.nvenc_twopass_full_res') }}</option>
    </SelectField>

    <!-- Spatial AQ -->
    <Checkbox id="nvenc_spatial_aq" locale-prefix="config" v-model="config.nvenc_spatial_aq" default="false"></Checkbox>

    <!-- Single-frame VBV/HRD percentage increase -->
    <TextField
      id="nvenc_vbv_increase"
      type="number"
      min="0"
      max="400"
      placeholder="0"
      :label="$t('config.nvenc_vbv_increase')"
      v-model="config.nvenc_vbv_increase"
    >
      <template #supporting>
        {{ $t('config.nvenc_vbv_increase_desc') }}
        <a href="https://en.wikipedia.org/wiki/Video_buffering_verifier" target="_blank">VBV/HRD</a>
      </template>
    </TextField>

    <!-- Miscellaneous options -->
    <Expander icon="tune" :title="$t('config.misc')">
      <div class="md-settings-group">
        <!-- NVENC Realtime HAGS priority -->
        <Checkbox
          v-if="platform === 'windows'"
          id="nvenc_realtime_hags"
          locale-prefix="config"
          v-model="config.nvenc_realtime_hags"
          default="true"
        >
          <a href="https://devblogs.microsoft.com/directx/hardware-accelerated-gpu-scheduling/" target="_blank">HAGS</a>
        </Checkbox>

        <!-- Prefer lower encoding latency over power savings -->
        <Checkbox
          v-if="platform === 'windows'"
          id="nvenc_latency_over_power"
          locale-prefix="config"
          v-model="config.nvenc_latency_over_power"
          default="true"
        ></Checkbox>

        <!-- Present OpenGL/Vulkan on top of DXGI -->
        <Checkbox
          v-if="platform === 'windows'"
          id="nvenc_opengl_vulkan_on_dxgi"
          locale-prefix="config"
          v-model="config.nvenc_opengl_vulkan_on_dxgi"
          default="true"
        ></Checkbox>

        <!-- NVENC H264 CAVLC -->
        <Checkbox id="nvenc_h264_cavlc" locale-prefix="config" v-model="config.nvenc_h264_cavlc" default="false"></Checkbox>

        <!-- NVENC Intra Refresh -->
        <SelectField
          id="nvenc_intra_refresh"
          :label="$t('config.nvenc_intra_refresh')"
          :supporting="$t('config.nvenc_intra_refresh_desc')"
          v-model="config.nvenc_intra_refresh"
        >
          <option value="disabled">{{ $t('_common.auto') }}</option>
          <option value="enabled">{{ $t('_common.enabled') }}</option>
        </SelectField>
      </div>
    </Expander>
  </div>
</template>

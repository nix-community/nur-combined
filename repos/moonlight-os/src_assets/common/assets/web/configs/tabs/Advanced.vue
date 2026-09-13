<script setup>
import { ref } from 'vue'
import PlatformLayout from '../../PlatformLayout.vue'
import Checkbox from "../../Checkbox.vue";
import SelectField from "../../SelectField.vue";
import TextField from "../../TextField.vue";

const props = defineProps([
  'platform',
  'config'
])

const config = ref(props.config)
</script>

<template>
  <div class="md-settings-group">
    <!-- FEC Percentage -->
    <TextField
      id="fec_percentage"
      placeholder="20"
      :label="$t('config.fec_percentage')"
      :supporting="$t('config.fec_percentage_desc')"
      v-model="config.fec_percentage"
    />

    <!-- Quantization Parameter -->
    <TextField
      id="qp"
      type="number"
      placeholder="28"
      :label="$t('config.qp')"
      :supporting="$t('config.qp_desc')"
      v-model="config.qp"
    />

    <!-- Min Threads -->
    <TextField
      id="min_threads"
      type="number"
      min="1"
      placeholder="2"
      :label="$t('config.min_threads')"
      :supporting="$t('config.min_threads_desc')"
      v-model="config.min_threads"
    />

    <!-- Limit Framerate -->
    <Checkbox id="limit_framerate" locale-prefix="config" v-model="config.limit_framerate" default="true"></Checkbox>
    <!-- ENVVAR compatibility mode -->
    <Checkbox id="envvar_compatibility_mode" locale-prefix="config" v-model="config.envvar_compatibility_mode" default="false"></Checkbox>
    <!-- Legacy ordering -->
    <Checkbox id="legacy_ordering" locale-prefix="config" v-model="config.legacy_ordering" default="false"></Checkbox>
    <!-- Ignore Encoder Probe Failure -->
    <Checkbox id="ignore_encoder_probe_failure" locale-prefix="config" v-model="config.ignore_encoder_probe_failure" default="false"></Checkbox>

    <!-- HEVC Support -->
    <SelectField
      id="hevc_mode"
      :label="$t('config.hevc_mode')"
      :supporting="$t('config.hevc_mode_desc')"
      v-model="config.hevc_mode"
    >
      <option v-for="n in 4" :key="n" :value="String(n - 1)">{{ $t(`config.hevc_mode_${n - 1}`) }}</option>
    </SelectField>

    <!-- AV1 Support -->
    <SelectField
      id="av1_mode"
      :label="$t('config.av1_mode')"
      :supporting="$t('config.av1_mode_desc')"
      v-model="config.av1_mode"
    >
      <option v-for="n in 4" :key="n" :value="String(n - 1)">{{ $t(`config.av1_mode_${n - 1}`) }}</option>
    </SelectField>

    <!-- Capture -->
    <SelectField
      v-if="platform !== 'macos'"
      id="capture"
      :label="$t('config.capture')"
      :supporting="$t('config.capture_desc')"
      v-model="config.capture"
    >
      <option value="">{{ $t('_common.autodetect') }}</option>
      <PlatformLayout :platform="platform">
        <template #linux>
          <option value="nvfbc">NvFBC</option>
          <option value="wlr">wlroots</option>
          <option value="kms">KMS</option>
          <option value="x11">X11</option>
        </template>
        <template #windows>
          <option value="ddx">Desktop Duplication API</option>
          <option value="wgc">Windows.Graphics.Capture {{ $t('_common.beta') }}</option>
        </template>
      </PlatformLayout>
    </SelectField>

    <!-- Encoder -->
    <SelectField
      id="encoder"
      :label="$t('config.encoder')"
      :supporting="$t('config.encoder_desc')"
      v-model="config.encoder"
    >
      <option value="">{{ $t('_common.autodetect') }}</option>
      <PlatformLayout :platform="platform">
        <template #windows>
          <option value="nvenc">NVIDIA NVENC</option>
          <option value="quicksync">Intel QuickSync</option>
          <option value="amdvce">AMD AMF/VCE</option>
        </template>
        <template #linux>
          <option value="nvenc">NVIDIA NVENC</option>
          <option value="vaapi">VA-API</option>
        </template>
        <template #macos>
          <option value="videotoolbox">VideoToolbox</option>
        </template>
      </PlatformLayout>
      <option value="software">{{ $t('config.encoder_software') }}</option>
    </SelectField>
  </div>
</template>

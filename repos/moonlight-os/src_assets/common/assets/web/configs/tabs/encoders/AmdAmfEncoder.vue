<script setup>
import { ref } from 'vue'
import Checkbox from "../../../Checkbox.vue";
import Expander from "../../../Expander.vue";
import SelectField from "../../../SelectField.vue";

const props = defineProps([
  'platform',
  'config',
])

const config = ref(props.config)
</script>

<template>
  <div id="amd-amf-encoder" class="md-settings-group">
    <!-- AMF Usage -->
    <SelectField
      id="amd_usage"
      :label="$t('config.amd_usage')"
      :supporting="$t('config.amd_usage_desc')"
      v-model="config.amd_usage"
    >
      <option value="transcoding">{{ $t('config.amd_usage_transcoding') }}</option>
      <option value="webcam">{{ $t('config.amd_usage_webcam') }}</option>
      <option value="lowlatency_high_quality">{{ $t('config.amd_usage_lowlatency_high_quality') }}</option>
      <option value="lowlatency">{{ $t('config.amd_usage_lowlatency') }}</option>
      <option value="ultralowlatency">{{ $t('config.amd_usage_ultralowlatency') }}</option>
    </SelectField>

    <!-- AMD Rate Control group options -->
    <Expander icon="speed" :title="$t('config.amd_rc_group')">
      <div class="md-settings-group">
        <!-- AMF Rate Control -->
        <SelectField
          id="amd_rc"
          :label="$t('config.amd_rc')"
          :supporting="$t('config.amd_rc_desc')"
          v-model="config.amd_rc"
        >
          <option value="cbr">{{ $t('config.amd_rc_cbr') }}</option>
          <option value="cqp">{{ $t('config.amd_rc_cqp') }}</option>
          <option value="vbr_latency">{{ $t('config.amd_rc_vbr_latency') }}</option>
          <option value="vbr_peak">{{ $t('config.amd_rc_vbr_peak') }}</option>
        </SelectField>

        <!-- AMF HRD Enforcement -->
        <Checkbox id="amd_enforce_hrd" locale-prefix="config" v-model="config.amd_enforce_hrd" default="false"></Checkbox>
      </div>
    </Expander>

    <!-- AMF Quality group options -->
    <Expander icon="high_quality" :title="$t('config.amd_quality_group')">
      <div class="md-settings-group">
        <!-- AMF Quality -->
        <SelectField
          id="amd_quality"
          :label="$t('config.amd_quality')"
          :supporting="$t('config.amd_quality_desc')"
          v-model="config.amd_quality"
        >
          <option value="speed">{{ $t('config.amd_quality_speed') }}</option>
          <option value="balanced">{{ $t('config.amd_quality_balanced') }}</option>
          <option value="quality">{{ $t('config.amd_quality_quality') }}</option>
        </SelectField>

        <!-- AMD Preanalysis -->
        <Checkbox id="amd_preanalysis" locale-prefix="config" v-model="config.amd_preanalysis" default="false"></Checkbox>
        <!-- AMD VBAQ -->
        <Checkbox id="amd_vbaq" locale-prefix="config" v-model="config.amd_vbaq" default="true"></Checkbox>

        <!-- AMF Coder (H264) -->
        <SelectField
          id="amd_coder"
          :label="$t('config.amd_coder')"
          :supporting="$t('config.amd_coder_desc')"
          v-model="config.amd_coder"
        >
          <option value="auto">{{ $t('config.ffmpeg_auto') }}</option>
          <option value="cabac">{{ $t('config.coder_cabac') }}</option>
          <option value="cavlc">{{ $t('config.coder_cavlc') }}</option>
        </SelectField>
      </div>
    </Expander>
  </div>
</template>

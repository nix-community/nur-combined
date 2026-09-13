<script setup>
import { ref } from 'vue'
import Checkbox from "../../../Checkbox.vue";
import SelectField from "../../../SelectField.vue";

const props = defineProps([
  'platform',
  'config',
])

const config = ref(props.config)
</script>

<template>
  <div id="intel-quicksync-encoder" class="md-settings-group">
    <!-- QuickSync Preset -->
    <SelectField id="qsv_preset" :label="$t('config.qsv_preset')" v-model="config.qsv_preset">
      <option value="veryfast">{{ $t('config.qsv_preset_veryfast') }}</option>
      <option value="faster">{{ $t('config.qsv_preset_faster') }}</option>
      <option value="fast">{{ $t('config.qsv_preset_fast') }}</option>
      <option value="medium">{{ $t('config.qsv_preset_medium') }}</option>
      <option value="slow">{{ $t('config.qsv_preset_slow') }}</option>
      <option value="slower">{{ $t('config.qsv_preset_slower') }}</option>
      <option value="slowest">{{ $t('config.qsv_preset_slowest') }}</option>
    </SelectField>

    <!-- QuickSync Coder (H264) -->
    <SelectField id="qsv_coder" :label="$t('config.qsv_coder')" v-model="config.qsv_coder">
      <option value="auto">{{ $t('config.ffmpeg_auto') }}</option>
      <option value="cabac">{{ $t('config.coder_cabac') }}</option>
      <option value="cavlc">{{ $t('config.coder_cavlc') }}</option>
    </SelectField>

    <!-- Allow Slow HEVC Encoding -->
    <Checkbox id="qsv_slow_hevc" locale-prefix="config" v-model="config.qsv_slow_hevc" default="false"></Checkbox>
  </div>
</template>

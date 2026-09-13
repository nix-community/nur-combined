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
  <div id="videotoolbox-encoder" class="md-settings-group">
    <!-- Presets -->
    <SelectField id="vt_coder" :label="$t('config.vt_coder')" v-model="config.vt_coder">
      <option value="auto">{{ $t('config.ffmpeg_auto') }}</option>
      <option value="cabac">{{ $t('config.coder_cabac') }}</option>
      <option value="cavlc">{{ $t('config.coder_cavlc') }}</option>
    </SelectField>

    <SelectField id="vt_software" :label="$t('config.vt_software')" v-model="config.vt_software">
      <option value="auto">{{ $t('_common.auto') }}</option>
      <option value="disabled">{{ $t('_common.disabled') }}</option>
      <option value="allowed">{{ $t('config.vt_software_allowed') }}</option>
      <option value="forced">{{ $t('config.vt_software_forced') }}</option>
    </SelectField>

    <Checkbox id="vt_realtime" desc="" locale-prefix="config" v-model="config.vt_realtime" default="true"></Checkbox>
  </div>
</template>

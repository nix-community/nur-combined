<script setup>
import { ref } from 'vue'
import SelectField from '../../../SelectField.vue'

const props = defineProps([
  'platform',
  'config'
])

const config = ref(props.config)

const PRESETS = ['ultrafast', 'superfast', 'veryfast', 'faster', 'fast', 'medium', 'slow', 'slower', 'veryslow']
const TUNES = ['film', 'animation', 'grain', 'stillimage', 'fastdecode', 'zerolatency']
</script>

<template>
  <div id="software-encoder" class="md-settings-group">
    <SelectField
      id="sw_preset"
      :label="$t('config.sw_preset')"
      :supporting="$t('config.sw_preset_desc')"
      v-model="config.sw_preset"
    >
      <option v-for="preset in PRESETS" :key="preset" :value="preset">{{ $t(`config.sw_preset_${preset}`) }}</option>
    </SelectField>

    <SelectField
      id="sw_tune"
      :label="$t('config.sw_tune')"
      :supporting="$t('config.sw_tune_desc')"
      v-model="config.sw_tune"
    >
      <option v-for="tune in TUNES" :key="tune" :value="tune">{{ $t(`config.sw_tune_${tune}`) }}</option>
    </SelectField>
  </div>
</template>

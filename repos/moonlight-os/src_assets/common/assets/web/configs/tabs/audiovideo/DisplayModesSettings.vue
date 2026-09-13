<script setup>
import { ref } from 'vue'
import TextField from '../../../TextField.vue'

const props = defineProps([
  'platform',
  'config',
])
const config = ref(props.config)
</script>

<template>
  <!--max_bitrate-->
  <TextField
    id="max_bitrate"
    type="number"
    placeholder="0"
    :label="$t('config.max_bitrate')"
    :supporting="$t('config.max_bitrate_desc')"
    v-model="config.max_bitrate"
  />

  <!--minimum_fps_target-->
  <TextField
    id="minimum_fps_target"
    type="number"
    min="0"
    max="1000"
    placeholder="0"
    :label="$t('config.minimum_fps_target')"
    :supporting="$t('config.minimum_fps_target_desc')"
    v-model="config.minimum_fps_target"
  />
</template>

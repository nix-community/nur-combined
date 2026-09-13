<script setup>
import { ref } from 'vue'
import TextField from '../../TextField.vue'

const props = defineProps([
  'platform',
  'config'
])

const config = ref(props.config)

const FILES = [
  { id: 'file_apps', placeholder: 'apps.json' },
  { id: 'credentials_file', placeholder: 'sunshine_state.json' },
  { id: 'log_path', placeholder: 'helios.log' },
  { id: 'pkey', placeholder: '/dir/pkey.pem' },
  { id: 'cert', placeholder: '/dir/cert.pem' },
  { id: 'file_state', placeholder: 'sunshine_state.json' },
]
</script>

<template>
  <div id="files" class="md-settings-group">
    <TextField
      v-for="file in FILES"
      :key="file.id"
      :id="file.id"
      monospace
      :placeholder="file.placeholder"
      :label="$t(`config.${file.id}`)"
      :supporting="$t(`config.${file.id}_desc`)"
      v-model="config[file.id]"
    />
  </div>
</template>

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
</script>

<template>
  <TextField
    v-if="platform !== 'macos'"
    id="adapter_name"
    :label="$t('config.adapter_name')"
    :placeholder="$tp('config.adapter_name_placeholder', '/dev/dri/renderD128')"
    v-model="config.adapter_name"
  >
    <template #supporting>
      <PlatformLayout :platform="platform">
        <template #windows>
          {{ $t('config.adapter_name_desc_windows') }}
          <pre>tools\dxgi-info.exe</pre>
        </template>
        <template #linux>
          {{ $t('config.adapter_name_desc_linux_1') }}
          <pre>ls /dev/dri/renderD*  # {{ $t('config.adapter_name_desc_linux_2') }}</pre>
          <pre>vainfo --display drm --device /dev/dri/renderD129 | \
  grep -E "((VAProfileH264High|VAProfileHEVCMain|VAProfileHEVCMain10).*VAEntrypointEncSlice)|Driver version"</pre>
          {{ $t('config.adapter_name_desc_linux_3') }}
          <pre>VAProfileH264High   : VAEntrypointEncSlice</pre>
        </template>
      </PlatformLayout>
    </template>
  </TextField>
</template>

<script setup>
import { ref } from 'vue'
import Checkbox from "../../../Checkbox.vue";

const props = defineProps([
  'platform',
  'config',
])

const config = ref(props.config)
</script>

<template>
  <div id="vaapi-encoder" class="md-settings-group">
    <!-- Strict RC Buffer -->
    <Checkbox id="vaapi_strict_rc_buffer" locale-prefix="config" v-model="config.vaapi_strict_rc_buffer" default="false"></Checkbox>
  </div>
</template>

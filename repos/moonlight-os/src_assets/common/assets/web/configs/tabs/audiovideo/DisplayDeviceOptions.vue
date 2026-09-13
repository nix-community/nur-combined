<script setup>
import { ref } from 'vue'
import PlatformLayout from '../../../PlatformLayout.vue'
import Banner from "../../../Banner.vue";
import Checkbox from "../../../Checkbox.vue";
import Expander from "../../../Expander.vue";
import SelectField from "../../../SelectField.vue";
import TextField from "../../../TextField.vue";

const props = defineProps({
  platform: String,
  config: Object
})
const config = ref(props.config)

const REFRESH_RATE_ONLY = "refresh_rate_only"
const RESOLUTION_ONLY = "resolution_only"
const MIXED = "mixed"

function canBeRemapped() {
  return (config.value.dd_resolution_option === "auto" || config.value.dd_refresh_rate_option === "auto")
    && config.value.dd_configuration_option !== "disabled";
}

function getRemappingType() {
  // Assuming here that at least one setting is set to "auto" if other is not
  if (config.value.dd_resolution_option !== "auto") {
    return REFRESH_RATE_ONLY;
  }
  if (config.value.dd_refresh_rate_option !== "auto") {
    return RESOLUTION_ONLY;
  }
  return MIXED;
}

function addRemappingEntry() {
  const type = getRemappingType();
  let template = {};

  if (type !== RESOLUTION_ONLY) {
    template["requested_fps"] = "";
    template["final_refresh_rate"] = "";
  }

  if (type !== REFRESH_RATE_ONLY) {
    template["requested_resolution"] = "";
    template["final_resolution"] = "";
  }

  config.value.dd_mode_remapping[type].push(template);
}
</script>

<template>
  <PlatformLayout :platform="platform">
    <template #windows>
      <Expander icon="display_settings" :title="$t('config.dd_options_header')" :open="false">
        <div class="md-settings-group">
          <Banner variant="info">
            {{ $t('config.dd_resolution_option_vdisplay_desc') }} {{ $t('config.dd_resolution_option_multi_instance_desc') }}
          </Banner>

          <!-- Configuration option -->
          <SelectField
            id="dd_configuration_option"
            :label="$t('config.dd_configuration_option')"
            v-model="config.dd_configuration_option"
          >
            <option value="disabled">{{ $t('_common.disabled_def') }}</option>
            <option value="verify_only">{{ $t('config.dd_config_verify_only') }}</option>
            <option value="ensure_active">{{ $t('config.dd_config_ensure_active') }}</option>
            <option value="ensure_primary">{{ $t('config.dd_config_ensure_primary') }}</option>
            <option value="ensure_only_display">{{ $t('config.dd_config_ensure_only_display') }}</option>
          </SelectField>

          <!-- Resolution option -->
          <div class="stack-sm" v-if="config.dd_configuration_option !== 'disabled'">
            <SelectField
              id="dd_resolution_option"
              :label="$t('config.dd_resolution_option')"
              :supporting="(config.dd_resolution_option === 'auto' || config.dd_resolution_option === 'manual') ? $t('config.dd_resolution_option_ogs_desc') : null"
              v-model="config.dd_resolution_option"
            >
              <option value="disabled">{{ $t('config.dd_resolution_option_disabled') }}</option>
              <option value="auto">{{ $t('config.dd_resolution_option_auto') }}</option>
              <option value="manual">{{ $t('config.dd_resolution_option_manual') }}</option>
            </SelectField>

            <!-- Manual resolution -->
            <TextField
              v-if="config.dd_resolution_option === 'manual'"
              class="helios-nested-field"
              id="dd_manual_resolution"
              placeholder="2560x1440"
              :label="$t('config.dd_manual_resolution')"
              v-model="config.dd_manual_resolution"
            />
          </div>

          <!-- Refresh rate option -->
          <div class="stack-sm" v-if="config.dd_configuration_option !== 'disabled'">
            <SelectField
              id="dd_refresh_rate_option"
              :label="$t('config.dd_refresh_rate_option')"
              v-model="config.dd_refresh_rate_option"
            >
              <option value="disabled">{{ $t('config.dd_refresh_rate_option_disabled') }}</option>
              <option value="auto">{{ $t('config.dd_refresh_rate_option_auto') }}</option>
              <option value="manual">{{ $t('config.dd_refresh_rate_option_manual') }}</option>
            </SelectField>

            <!-- Manual refresh rate -->
            <TextField
              v-if="config.dd_refresh_rate_option === 'manual'"
              class="helios-nested-field"
              id="dd_manual_refresh_rate"
              placeholder="59.9558"
              :label="$t('config.dd_manual_refresh_rate')"
              v-model="config.dd_manual_refresh_rate"
            />
          </div>

          <!-- Config revert delay -->
          <TextField
            v-if="config.dd_configuration_option !== 'disabled'"
            id="dd_config_revert_delay"
            type="number"
            min="0"
            placeholder="3000"
            :label="$t('config.dd_config_revert_delay')"
            :supporting="$t('config.dd_config_revert_delay_desc')"
            v-model="config.dd_config_revert_delay"
          />

          <!-- Config revert on disconnect -->
          <Checkbox
            v-if="config.dd_configuration_option !== 'disabled'"
            id="dd_config_revert_on_disconnect"
            locale-prefix="config"
            v-model="config.dd_config_revert_on_disconnect"
            default="false"
          ></Checkbox>

          <!-- Display mode remapping -->
          <div class="stack-sm" v-if="canBeRemapped()" id="dd_mode_remapping">
            <div class="md-title-small">{{ $t('config.dd_mode_remapping') }}</div>
            <div class="md-body-small text-muted">
              {{ $t('config.dd_mode_remapping_desc_1') }}<br>
              {{ $t('config.dd_mode_remapping_desc_2') }}<br>
              {{ $t('config.dd_mode_remapping_desc_3') }}<br>
              {{ $t(getRemappingType() === MIXED ? 'config.dd_mode_remapping_desc_4_final_values_mixed' : 'config.dd_mode_remapping_desc_4_final_values_non_mixed') }}<br>
              <template v-if="getRemappingType() === MIXED">
                {{ $t('config.dd_mode_remapping_desc_5_sops_mixed_only') }}<br>
              </template>
              <template v-if="getRemappingType() === RESOLUTION_ONLY">
                {{ $t('config.dd_mode_remapping_desc_5_sops_resolution_only') }}<br>
              </template>
            </div>

            <div class="md-table-scroll" v-if="config.dd_mode_remapping[getRemappingType()].length > 0">
              <table class="md-table">
                <thead>
                  <tr>
                    <th v-if="getRemappingType() !== REFRESH_RATE_ONLY">
                      {{ $t('config.dd_mode_remapping_requested_resolution') }}
                    </th>
                    <th v-if="getRemappingType() !== RESOLUTION_ONLY">
                      {{ $t('config.dd_mode_remapping_requested_fps') }}
                    </th>
                    <th v-if="getRemappingType() !== REFRESH_RATE_ONLY">
                      {{ $t('config.dd_mode_remapping_final_resolution') }}
                    </th>
                    <th v-if="getRemappingType() !== RESOLUTION_ONLY">
                      {{ $t('config.dd_mode_remapping_final_refresh_rate') }}
                    </th>
                    <!-- Additional columns for buttons-->
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(value, idx) in config.dd_mode_remapping[getRemappingType()]" :key="idx">
                    <td v-if="getRemappingType() !== REFRESH_RATE_ONLY">
                      <TextField dense monospace :id="`remap-req-res-${idx}`" placeholder="1920x1080" v-model="value.requested_resolution" />
                    </td>
                    <td v-if="getRemappingType() !== RESOLUTION_ONLY">
                      <TextField dense monospace :id="`remap-req-fps-${idx}`" placeholder="60" v-model="value.requested_fps" />
                    </td>
                    <td v-if="getRemappingType() !== REFRESH_RATE_ONLY">
                      <TextField dense monospace :id="`remap-final-res-${idx}`" placeholder="2560x1440" v-model="value.final_resolution" />
                    </td>
                    <td v-if="getRemappingType() !== RESOLUTION_ONLY">
                      <TextField dense monospace :id="`remap-final-fps-${idx}`" placeholder="119.95" v-model="value.final_refresh_rate" />
                    </td>
                    <td>
                      <div class="md-table__actions">
                        <button
                          class="md-icon-button md-icon-button--danger"
                          :aria-label="$t('_common.remove')"
                          @click="config.dd_mode_remapping[getRemappingType()].splice(idx, 1)"
                        >
                          <Icon name="delete" />
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <button class="md-button md-button--tonal self-start" @click="addRemappingEntry()">
              <Icon name="add" />{{ $t('config.dd_mode_remapping_add') }}
            </button>
          </div>
        </div>
      </Expander>

      <!-- HDR option -->
      <SelectField id="dd_hdr_option" :label="$t('config.dd_hdr_option')" v-model="config.dd_hdr_option">
        <option value="disabled">{{ $t('config.dd_hdr_option_disabled') }}</option>
        <option value="auto">{{ $t('config.dd_hdr_option_auto') }}</option>
      </SelectField>
    </template>
    <template #linux>
    </template>
    <template #macos>
    </template>
  </PlatformLayout>
</template>

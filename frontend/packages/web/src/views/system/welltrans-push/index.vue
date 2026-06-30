<template>
  <n-scrollbar content-class="overflow-auto">
    <div class="welltrans-push-container p-[24px]">
      <!-- 配置区域 -->
      <CrmCard
        :title="t('menu.settings.welltransPush')"
        auto-height
        hide-footer
        class="mb-[16px]"
      >
        <n-form
          ref="formRef"
          label-placement="left"
          :model="form"
          class="!w-[560px]"
          require-mark-placement="left"
          :label-width="140"
        >
          <n-form-item :label="t('system.welltrans.apiUrl')" path="apiUrl">
            <n-input
              v-model:value="form.apiUrl"
              :maxlength="500"
              :placeholder="t('system.welltrans.apiUrlPlaceholder')"
              clearable
            />
          </n-form-item>
          <n-form-item :label="t('system.welltrans.apiKey')" path="apiKey">
            <n-input
              v-model:value="form.apiKey"
              type="password"
              show-password-on="click"
              :maxlength="255"
              :placeholder="t('system.welltrans.apiKeyPlaceholder')"
              clearable
            />
          </n-form-item>
          <n-form-item
            :label="t('system.welltrans.autoPush')"
            path="autoPushEnabled"
          >
            <n-switch
              v-model:value="form.autoPushEnabled"
              :rubber-band="false"
            />
          </n-form-item>
          <n-form-item
            :label="t('system.welltrans.manualPush')"
            path="manualPushEnabled"
          >
            <n-switch
              v-model:value="form.manualPushEnabled"
              :rubber-band="false"
            />
          </n-form-item>
        </n-form>
        <n-divider class="!m-0" />
        <div class="my-[12px] mr-[24px] flex justify-end gap-[8px]">
          <n-button
            v-permission="['SYSTEM_SETTING:UPDATE']"
            type="primary"
            ghost
            :loading="pushing"
            @click="handleExecutePush"
          >
            {{
              pushing
                ? t("system.welltrans.pushing")
                : t("system.welltrans.executePush")
            }}
          </n-button>
          <n-button
            v-permission="['SYSTEM_SETTING:UPDATE']"
            type="primary"
            :loading="saving"
            @click="handleSaveConfig"
          >
            {{ t("system.welltrans.saveConfig") }}
          </n-button>
        </div>
      </CrmCard>

      <!-- 推送结果 -->
      <CrmCard
        v-if="lastResult"
        :title="t('system.welltrans.pushResult')"
        auto-height
        hide-footer
        class="mb-[16px]"
      >
        <n-descriptions :column="4" label-placement="left" class="p-[16px]">
          <n-descriptions-item :label="t('system.welltrans.totalCount')">{{
            lastResult.totalCount
          }}</n-descriptions-item>
          <n-descriptions-item :label="t('system.welltrans.successCount')">
            <span class="text-[var(--success-green)]">{{
              lastResult.successCount
            }}</span>
          </n-descriptions-item>
          <n-descriptions-item :label="t('system.welltrans.failCount')">
            <span
              :class="lastResult.failCount > 0 ? 'text-[var(--error-red)]' : ''"
              >{{ lastResult.failCount }}</span
            >
          </n-descriptions-item>
          <n-descriptions-item :label="t('system.welltrans.errorMessage')">
            <span
              v-if="lastResult.errorMessage"
              class="text-[var(--error-red)]"
              >{{ lastResult.errorMessage }}</span
            >
            <span v-else>-</span>
          </n-descriptions-item>
        </n-descriptions>
      </CrmCard>

      <!-- 推送历史 -->
      <CrmCard
        :title="t('system.welltrans.pushHistory')"
        auto-height
        hide-footer
      >
        <n-data-table
          :columns="logColumns"
          :data="pushLogs"
          :loading="logsLoading"
          :empty-text="t('system.welltrans.noLogs')"
          :pagination="{ pageSize: 10 }"
          class="p-[16px]"
          size="small"
        />
      </CrmCard>
    </div>
  </n-scrollbar>
</template>

<script setup lang="ts">
import {
  NButton,
  NDataTable,
  NDescriptions,
  NDescriptionsItem,
  NDivider,
  NForm,
  NFormItem,
  NInput,
  NScrollbar,
  NSwitch,
  useMessage,
} from "naive-ui";

import { useI18n } from "@lib/shared/hooks/useI18n";
import type {
  WelltransPushLog,
  WelltransPushResult,
} from "@lib/shared/models/system/business";

import CrmCard from "@/components/pure/crm-card/index.vue";

import {
  executeWelltransPush,
  getWelltransConfig,
  getWelltransPushLogs,
  saveWelltransConfig,
} from "@/api/modules";

import type { DataTableColumn } from "naive-ui";

const { t } = useI18n();
const Message = useMessage();

const saving = ref(false);
const pushing = ref(false);
const logsLoading = ref(false);
const lastResult = ref<WelltransPushResult | null>(null);
const pushLogs = ref<WelltransPushLog[]>([]);

const form = ref({
  apiUrl: "",
  apiKey: "",
  autoPushEnabled: false,
  manualPushEnabled: false,
});

const logColumns: DataTableColumn<WelltransPushLog>[] = [
  {
    title: t("system.welltrans.triggerType"),
    key: "triggerType",
    width: 100,
    render: (row) =>
      row.triggerType === "AUTO"
        ? t("system.welltrans.triggerAuto")
        : t("system.welltrans.triggerManual"),
  },
  {
    title: t("system.welltrans.totalCount"),
    key: "totalCount",
    width: 80,
  },
  {
    title: t("system.welltrans.successCount"),
    key: "successCount",
    width: 80,
  },
  {
    title: t("system.welltrans.failCount"),
    key: "failCount",
    width: 80,
  },
  {
    title: t("system.welltrans.errorMessage"),
    key: "errorMessage",
    ellipsis: { tooltip: true },
  },
  {
    title: t("system.welltrans.executeTime"),
    key: "createTime",
    width: 180,
    render: (row) => new Date(row.createTime).toLocaleString(),
  },
];

async function loadConfig() {
  try {
    const res = await getWelltransConfig();
    form.value = {
      apiUrl: res.apiUrl || "",
      apiKey: res.apiKey || "",
      autoPushEnabled: res.autoPushEnabled || false,
      manualPushEnabled: res.manualPushEnabled || false,
    };
  } catch (error) {
    // eslint-disable-next-line no-console
    console.log(error);
  }
}

async function loadLogs() {
  try {
    logsLoading.value = true;
    pushLogs.value = await getWelltransPushLogs();
  } catch (error) {
    // eslint-disable-next-line no-console
    console.log(error);
  } finally {
    logsLoading.value = false;
  }
}

async function handleSaveConfig() {
  try {
    saving.value = true;
    await saveWelltransConfig(form.value);
    Message.success(t("common.updateSuccess"));
  } catch (error: any) {
    Message.error(error?.message || t("common.operateFail"));
  } finally {
    saving.value = false;
  }
}

async function handleExecutePush() {
  try {
    pushing.value = true;
    lastResult.value = await executeWelltransPush();
    if (lastResult.value?.success) {
      Message.success(t("common.operateSuccess"));
    } else {
      Message.error(lastResult.value?.errorMessage || t("common.operateFail"));
    }
    await loadLogs();
  } catch (error: any) {
    Message.error(error?.message || t("common.operateFail"));
  } finally {
    pushing.value = false;
  }
}

onBeforeMount(() => {
  loadConfig();
  loadLogs();
});
</script>

<style lang="less" scoped>
.welltrans-push-container {
  max-width: 1000px;
}
</style>

<template>
  <n-form-item
    :label="props.fieldConfig.name"
    :path="props.path"
    :rule="props.fieldConfig.rules"
    :required="props.fieldConfig.rules.some((rule) => rule.key === 'required')"
    :label-placement="props.isSubTableField || props.isSubTableRender ? 'top' : props.formConfig?.labelPos"
    :show-label="!props.isSubTableRender"
  >
    <template #label>
      <div v-if="props.fieldConfig.showLabel" class="flex h-[22px] items-center gap-[4px] whitespace-nowrap">
        <div class="one-line-text">{{ props.fieldConfig.name }}</div>
        <CrmIcon v-if="props.fieldConfig.resourceFieldId" type="iconicon_correlation" />
      </div>
      <div v-else class="h-[22px]"></div>
    </template>
    <div
      v-if="props.fieldConfig.description"
      class="crm-form-create-item-desc"
      v-html="props.fieldConfig.description"
    ></div>
    <n-divider v-if="props.isSubTableField && !props.isSubTableRender" class="!my-0" />
    <n-checkbox-group
      v-model:value="value"
      :disabled="props.fieldConfig.editable === false || !!props.fieldConfig.resourceFieldId"
      @update-value="($event) => emit('change', $event)"
    >
      <n-space :item-class="props.fieldConfig.direction === 'horizontal' ? '' : 'w-full'">
        <n-checkbox
          v-for="item in checkboxOptions"
          :key="item.value"
          :value="item.value"
        >
          <span v-if="item.color" class="mr-[4px] font-bold" :style="{ color: item.color }">●</span>{{ item.label }}
        </n-checkbox>
      </n-space>
    </n-checkbox-group>
  </n-form-item>
</template>

<script setup lang="ts">
  import { NCheckbox, NCheckboxGroup, NDivider, NFormItem, NSpace } from 'naive-ui';

  import type { FormConfig } from '@lib/shared/models/system/module';

  import { getDictItemsByCode } from '@/api/modules';
  import { FormCreateField } from '../../types';

  const props = defineProps<{
    fieldConfig: FormCreateField;
    formConfig?: FormConfig;
    path: string;
    needInitDetail?: boolean; // 判断是否编辑情况
    isSubTableField?: boolean; // 是否是子表字段
    isSubTableRender?: boolean; // 是否是子表渲染
  }>();
  const emit = defineEmits<{
    (e: 'change', value: (string | number)[]): void;
  }>();

  const value = defineModel<(string | number)[]>('value', {
    default: [],
  });

  const dictOpts = ref<{ label: string; value: string; color?: string }[]>([]);
  const checkboxOptions = computed(() =>
    props.fieldConfig.dictCode ? dictOpts.value : (props.fieldConfig.options || [])
  );
  async function loadDictOpts() {
    if (!props.fieldConfig.dictCode) return;
    try {
      const items = await getDictItemsByCode(props.fieldConfig.dictCode);
      dictOpts.value = (items || []).map((item: any) => ({ label: item.label, value: item.value, color: item.color || '' }));
    } catch { /* ignore */ }
  }
  watch(() => props.fieldConfig.dictCode, loadDictOpts, { immediate: true });

  watch(
    () => props.fieldConfig.defaultValue,
    (val) => {
      if (!props.needInitDetail) {
        value.value = val || value.value;
        emit('change', value.value);
      }
    },
    {
      immediate: true,
    }
  );
</script>

<style lang="less" scoped></style>

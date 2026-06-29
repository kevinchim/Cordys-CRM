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
      v-if="props.fieldConfig.description && !props.isSubTableRender"
      class="crm-form-create-item-desc"
      v-html="props.fieldConfig.description"
    ></div>
    <n-divider v-if="props.isSubTableField && !props.isSubTableRender" class="!my-0" />
    <n-select
      v-model:value="value"
      :disabled="props.fieldConfig.editable === false || !!props.fieldConfig.resourceFieldId"
      :options="options"
      :multiple="props.fieldConfig.type === FieldTypeEnum.SELECT_MULTIPLE"
      :placeholder="props.fieldConfig.placeholder"
      :fallback-option="value !== null && value !== undefined && value !== '' ? fallbackOption : false"
      :render-option="renderOption"
      max-tag-count="responsive"
      clearable
      :render-label="renderOptionLabel"
      :render-option="renderOptionLabel"
    />
  </n-form-item>
</template>

<script setup lang="ts">
  import { h, VNode, VNodeChild } from 'vue';
  import { NDivider, NFormItem, NSelect, NTooltip, SelectOption } from 'naive-ui';

  import { FieldTypeEnum } from '@lib/shared/enums/formDesignEnum';
  import { useI18n } from '@lib/shared/hooks/useI18n';
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
    (e: 'change', value: string | number | (string | number)[]): void;
  }>();

  const { t } = useI18n();

  const value = defineModel<string | number | (string | number)[]>('value', {
    default: '',
  });

  const dictOpts = ref<{ label: string; value: string; color?: string }[]>([]);

  // 优先显示 dictOpts（从 API 加载），fallback 到 options（表单配置中保存的）
  const resolvedOptions = computed(() => {
    if (dictOpts.value.length > 0) return dictOpts.value;
    return props.fieldConfig.options || [];
  });

  const options = computed(() => {
    if (props.fieldConfig.linkRange) {
      return resolvedOptions.value.filter((option) => props.fieldConfig.linkRange?.includes(option.value)) || [];
    }
    return resolvedOptions.value;
  });

  async function loadDictOpts() {
    // 优先用 dictCode 加载；如果没有 dictCode 但有 optionSource==='dict' 且 options 为空，尝试用 options 里的第一个 value 作为 code
    const code = props.fieldConfig.dictCode;
    if (!code) return;
    try {
      const items = await getDictItemsByCode(code);
      if (items && items.length > 0) {
        dictOpts.value = items.map((item: any) => ({ label: item.label, value: item.value, color: item.color || '' }));
      }
    } catch { /* ignore */ }
  }

  function renderOptionLabel(option: any) {
    const children = [];
    if (option.color) {
      children.push(h('span', { style: { color: option.color, marginRight: '6px', fontWeight: 'bold' } }, '●'));
    }
    children.push(h('span', option.label));
    return h('span', children);
  }

  watch(() => props.fieldConfig.dictCode, loadDictOpts, { immediate: true });
  // also load when component first mounts with optionSource === 'dict'
  onBeforeMount(() => {
    if (props.fieldConfig.optionSource === 'dict') loadDictOpts();
  });

  watch(
    () => props.fieldConfig.defaultValue,
    (val) => {
      if (!props.needInitDetail) {
        value.value = value.value || val || (props.fieldConfig.type === FieldTypeEnum.SELECT_MULTIPLE ? [] : '');
        emit('change', value.value);
      }
    }
  );

  watch(
    () => value.value,
    (val) => {
      emit('change', val);
    }
  );

  function fallbackOption(val: string | number) {
    return {
      label: t('common.optionNotExist'),
      value: val,
    };
  }

  function renderOption({ node, option }: { node: VNode; option: SelectOption }): VNodeChild {
    return h(
      NTooltip,
      {
        delay: 300,
      },
      {
        trigger: () => node,
        default: () => option.label,
      }
    );
  }

  onBeforeMount(() => {
    if (!props.needInitDetail) {
      value.value =
        value.value ||
        props.fieldConfig.defaultValue ||
        (props.fieldConfig.type === FieldTypeEnum.SELECT_MULTIPLE ? [] : '');
      emit('change', value.value);
    }
  });
</script>

<style lang="less" scoped></style>

<template>
  <n-scrollbar content-class="h-full overflow-auto">
    <div class="dict-manage-container p-[24px]">
      <div class="flex gap-[16px]">
        <!-- 左侧：分类列表 -->
        <CrmCard
          :title="t('dict.category')"
          auto-height
          hide-footer
          class="w-[400px] flex-shrink-0"
        >
          <template #header-extra>
            <n-button
              v-permission="['DICT_MANAGE:ADD']"
              size="small"
              type="primary"
              @click="openCatDrawer()"
            >
              {{ t("common.add") }}
            </n-button>
          </template>
          <n-list hoverable clickable>
            <n-list-item
              v-for="cat in categories"
              :key="cat.id"
              @click="selectCat(cat)"
            >
              <template #prefix>
                <n-tag
                  :bordered="false"
                  size="small"
                  :type="cat.enabled ? 'success' : 'default'"
                  class="mr-[8px]"
                >
                  {{ cat.enabled ? t("dict.enabled") : t("dict.disabled") }}
                </n-tag>
              </template>
              <div class="flex w-full items-center justify-between">
                <div>
                  <div class="text-[14px] font-medium">{{ cat.name }}</div>
                  <div class="text-[12px] text-[var(--text-n4)]">
                    {{ cat.code }}
                  </div>
                </div>
                <div>
                  <n-button
                    v-permission="['DICT_MANAGE:UPDATE']"
                    text
                    size="tiny"
                    @click.stop="openCatDrawer(cat)"
                    >{{ t("common.edit") }}</n-button
                  >
                  <n-popconfirm @positive-click="delCat(cat.id)">
                    <template #trigger>
                      <n-button
                        v-permission="['DICT_MANAGE:DELETE']"
                        text
                        size="tiny"
                        type="error"
                        >{{ t("common.delete") }}</n-button
                      >
                    </template>
                    {{ t("common.confirmDelete") }}
                  </n-popconfirm>
                </div>
              </div>
            </n-list-item>
          </n-list>
          <n-empty
            v-if="categories.length === 0"
            :description="t('dict.noCategories')"
            class="py-[40px]"
          />
        </CrmCard>

        <!-- 右侧：字典项 -->
        <CrmCard
          :title="
            selCat
              ? selCat.name + ' — ' + t('dict.items')
              : t('dict.selectCategory')
          "
          auto-height
          hide-footer
          class="flex-1"
        >
          <template v-if="selCat" #header-extra>
            <n-button
              v-permission="['DICT_MANAGE:ADD']"
              size="small"
              type="primary"
              @click="openItemDrawer()"
            >
              {{ t("dict.addItem") }}
            </n-button>
          </template>
          <n-data-table
            :columns="itemCols"
            :data="items"
            size="small"
            :pagination="false"
          />
          <n-empty
            v-if="!selCat"
            :description="t('dict.selectCategoryHint')"
            class="py-[80px]"
          />
          <n-empty
            v-else-if="items.length === 0"
            :description="t('dict.noItems')"
            class="py-[40px]"
          />
        </CrmCard>
      </div>

      <!-- 分类编辑抽屉 -->
      <CrmDrawer
        v-model:show="catShow"
        :width="480"
        :title="editingCat?.id ? t('dict.editCategory') : t('dict.addCategory')"
        :loading="catSaving"
        @confirm="saveCat"
      >
        <n-form :model="catForm" label-placement="left" :label-width="80">
          <n-form-item :label="t('dict.code')" required
            ><n-input
              v-model:value="catForm.code"
              :disabled="!!editingCat?.id"
              :placeholder="t('dict.codePlaceholder')"
              :maxlength="64"
          /></n-form-item>
          <n-form-item :label="t('dict.name')" required
            ><n-input
              v-model:value="catForm.name"
              :placeholder="t('dict.namePlaceholder')"
              :maxlength="255"
          /></n-form-item>
          <n-form-item :label="t('dict.description')"
            ><n-input
              v-model:value="catForm.description"
              type="textarea"
              :maxlength="500"
          /></n-form-item>
          <n-form-item :label="t('dict.sort')"
            ><n-input-number v-model:value="catForm.pos" :min="0"
          /></n-form-item>
          <n-form-item :label="t('dict.enabled')"
            ><n-switch v-model:value="catForm.enabled"
          /></n-form-item>
        </n-form>
      </CrmDrawer>

      <!-- 字典项编辑抽屉 -->
      <CrmDrawer
        v-model:show="itemShow"
        :width="480"
        :title="editingItem?.id ? t('dict.editItem') : t('dict.addItem')"
        :loading="itemSaving"
        @confirm="saveItem"
      >
        <n-form :model="itemForm" label-placement="left" :label-width="80">
          <n-form-item :label="t('dict.itemValue')" required
            ><n-input v-model:value="itemForm.value" :maxlength="255"
          /></n-form-item>
          <n-form-item :label="t('dict.itemLabel')" required
            ><n-input v-model:value="itemForm.label" :maxlength="255"
          /></n-form-item>
          <n-form-item :label="t('dict.itemColor')"
            ><n-color-picker v-model:value="itemForm.color" :show-alpha="false"
          /></n-form-item>
          <n-form-item :label="t('dict.sort')"
            ><n-input-number v-model:value="itemForm.pos" :min="0"
          /></n-form-item>
          <n-form-item :label="t('dict.enabled')"
            ><n-switch v-model:value="itemForm.enabled"
          /></n-form-item>
        </n-form>
      </CrmDrawer>
    </div>
  </n-scrollbar>
</template>

<script setup lang="ts">
import {
  NButton,
  NColorPicker,
  NDataTable,
  NEmpty,
  NForm,
  NFormItem,
  NInput,
  NInputNumber,
  NList,
  NListItem,
  NPopconfirm,
  NScrollbar,
  NSwitch,
  NTag,
  useMessage,
} from "naive-ui";

import { useI18n } from "@lib/shared/hooks/useI18n";

import CrmCard from "@/components/pure/crm-card/index.vue";
import CrmDrawer from "@/components/pure/crm-drawer/index.vue";

import {
  addDictCategory,
  addDictItem,
  deleteDictCategory,
  deleteDictItem,
  getDictCategories,
  getDictItems,
  updateDictCategory,
  updateDictItem,
} from "@/api/modules";

import type { DataTableColumn } from "naive-ui";

const { t } = useI18n();
const Message = useMessage();

// ============ 分类 ============
const categories = ref<any[]>([]);
const selCat = ref<any>(null);
const catShow = ref(false);
const catSaving = ref(false);
const editingCat = ref<any>(null);
const catForm = ref({
  code: "",
  name: "",
  description: "",
  pos: 0,
  enabled: true,
});

const items = ref<any[]>([]);

async function loadCats() {
  categories.value = (await getDictCategories()) || [];
}
async function loadItems() {
  if (!selCat.value) return;
  items.value = (await getDictItems(selCat.value.id)) || [];
}
function selectCat(cat: any) {
  selCat.value = cat;
  loadItems();
}
function openCatDrawer(cat?: any) {
  editingCat.value = cat || null;
  catForm.value = cat
    ? {
        code: cat.code,
        name: cat.name,
        description: cat.description || "",
        pos: cat.pos,
        enabled: cat.enabled,
      }
    : { code: "", name: "", description: "", pos: 0, enabled: true };
  catShow.value = true;
}
async function saveCat() {
  catSaving.value = true;
  try {
    const data = { ...catForm.value };
    if (editingCat.value?.id) {
      (data as any).id = editingCat.value.id;
      await updateDictCategory(data);
    } else {
      await addDictCategory(data);
    }
    Message.success(t("common.updateSuccess"));
    catShow.value = false;
    await loadCats();
  } catch (e: any) {
    Message.error(e?.message || t("common.operateFail"));
  } finally {
    catSaving.value = false;
  }
}
async function delCat(id: string) {
  await deleteDictCategory(id);
  Message.success(t("common.deleteSuccess"));
  if (selCat.value?.id === id) selCat.value = null;
  await loadCats();
}

// ============ 字典项 ============
const itemShow = ref(false);
const itemSaving = ref(false);
const editingItem = ref<any>(null);
const itemForm = ref({
  value: "",
  label: "",
  color: "",
  pos: 0,
  enabled: true,
});

function openItemDrawer(item?: any) {
  editingItem.value = item || null;
  itemForm.value = item
    ? {
        value: item.value,
        label: item.label,
        color: item.color || "",
        pos: item.pos,
        enabled: item.enabled,
      }
    : { value: "", label: "", color: "", pos: 0, enabled: true };
  itemShow.value = true;
}
async function saveItem() {
  if (!selCat.value) return;
  itemSaving.value = true;
  try {
    const data: any = { ...itemForm.value, categoryId: selCat.value.id };
    if (editingItem.value?.id) {
      data.id = editingItem.value.id;
      await updateDictItem(data);
    } else {
      await addDictItem(data);
    }
    Message.success(t("common.updateSuccess"));
    itemShow.value = false;
    await loadItems();
  } catch (e: any) {
    Message.error(e?.message || t("common.operateFail"));
  } finally {
    itemSaving.value = false;
  }
}
async function delItem(id: string) {
  await deleteDictItem(id);
  Message.success(t("common.deleteSuccess"));
  await loadItems();
}

const itemCols: DataTableColumn[] = [
  { title: t("dict.itemLabel"), key: "label", width: 150 },
  { title: t("dict.itemValue"), key: "value", width: 120 },
  { title: t("dict.sort"), key: "pos", width: 60 },
  {
    title: t("dict.itemColor"),
    key: "color",
    width: 100,
    render: (row: any) =>
      row.color
        ? h(
            "span",
            { style: { color: row.color, fontWeight: "bold" } },
            `● ${row.color}`
          )
        : "-",
  },
  {
    title: t("dict.enabled"),
    key: "enabled",
    width: 70,
    render: (row: any) =>
      row.enabled ? t("dict.enabled") : t("dict.disabled"),
  },
  {
    title: t("common.operation"),
    key: "action",
    width: 100,
    render: (row: any) =>
      h("div", [
        h(
          NButton,
          { size: "tiny", text: true, onClick: () => openItemDrawer(row) },
          () => t("common.edit")
        ),
        h(
          NPopconfirm,
          { onPositiveClick: () => delItem(row.id) },
          {
            trigger: () =>
              h(NButton, { size: "tiny", text: true, type: "error" }, () =>
                t("common.delete")
              ),
            default: () => t("common.confirmDelete"),
          }
        ),
      ]),
  },
];

onBeforeMount(() => loadCats());
</script>

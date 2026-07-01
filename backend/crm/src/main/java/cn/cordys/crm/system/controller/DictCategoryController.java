package cn.cordys.crm.system.controller;

import cn.cordys.common.constants.PermissionConstants;
import cn.cordys.context.OrganizationContext;
import cn.cordys.crm.system.domain.DictCategory;
import cn.cordys.crm.system.domain.DictItem;
import cn.cordys.crm.system.dto.request.*;
import cn.cordys.crm.system.service.DictCategoryService;
import cn.cordys.security.SessionUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/dict-category")
@Tag(name = "系统设置-字典管理")
public class DictCategoryController {

    @Resource
    private DictCategoryService dictCategoryService;

    // ==================== 分类 ====================

    @GetMapping("/list")
    @Operation(summary = "获取字典分类列表")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_READ})
    public List<DictCategory> listCategories() {
        return dictCategoryService.listCategories(OrganizationContext.getOrganizationId());
    }

    @PostMapping("/add")
    @Operation(summary = "新增字典分类")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_ADD})
    public void addCategory(@Validated @RequestBody DictCategoryAddRequest request) {
        dictCategoryService.addCategory(request, SessionUtils.getUserId(), OrganizationContext.getOrganizationId());
    }

    @PostMapping("/update")
    @Operation(summary = "修改字典分类")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_UPDATE})
    public void updateCategory(@Validated @RequestBody DictCategoryUpdateRequest request) {
        dictCategoryService.updateCategory(request, SessionUtils.getUserId(), OrganizationContext.getOrganizationId());
    }

    @GetMapping("/delete/{id}")
    @Operation(summary = "删除字典分类")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_DELETE})
    public void deleteCategory(
            @Schema(description = "分类ID", requiredMode = Schema.RequiredMode.REQUIRED)
            @PathVariable("id") String id) {
        dictCategoryService.deleteCategory(id);
    }

    // ==================== 字典项 ====================

    @GetMapping("/{categoryId}/items")
    @Operation(summary = "获取分类下的字典项列表")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_READ})
    public List<DictItem> listItems(
            @Schema(description = "分类ID", requiredMode = Schema.RequiredMode.REQUIRED)
            @PathVariable("categoryId") String categoryId) {
        return dictCategoryService.listItems(categoryId);
    }

    @GetMapping("/items/by-code/{code}")
    @Operation(summary = "按分类编码获取字典项（供其他模块调用）")
    public List<DictItem> getItemsByCode(
            @Schema(description = "分类编码", requiredMode = Schema.RequiredMode.REQUIRED)
            @PathVariable("code") String code) {
        return dictCategoryService.getItemsByCode(code, OrganizationContext.getOrganizationId());
    }

    @PostMapping("/item/add")
    @Operation(summary = "新增字典项")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_ADD})
    public void addItem(@Validated @RequestBody DictItemAddRequest request) {
        dictCategoryService.addItem(request, SessionUtils.getUserId());
    }

    @PostMapping("/item/update")
    @Operation(summary = "修改字典项")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_UPDATE})
    public void updateItem(@Validated @RequestBody DictItemUpdateRequest request) {
        dictCategoryService.updateItem(request, SessionUtils.getUserId());
    }

    @GetMapping("/item/delete/{id}")
    @Operation(summary = "删除字典项")
    @RequiresPermissions(value = {PermissionConstants.DICT_MANAGE_DELETE})
    public void deleteItem(
            @Schema(description = "字典项ID", requiredMode = Schema.RequiredMode.REQUIRED)
            @PathVariable("id") String id) {
        dictCategoryService.deleteItem(id);
    }
}

package cn.cordys.crm.system.service;

import cn.cordys.common.exception.GenericException;
import cn.cordys.common.uid.IDGenerator;
import cn.cordys.common.util.BeanUtils;
import cn.cordys.common.util.Translator;
import cn.cordys.crm.system.domain.DictCategory;
import cn.cordys.crm.system.domain.DictItem;
import cn.cordys.crm.system.dto.request.*;
import cn.cordys.mybatis.BaseMapper;
import cn.cordys.mybatis.lambda.LambdaQueryWrapper;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;

@Service
@Transactional(rollbackFor = Exception.class)
public class DictCategoryService {

    @Resource
    private BaseMapper<DictCategory> dictCategoryMapper;
    @Resource
    private BaseMapper<DictItem> dictItemMapper;

    // ==================== 分类 ====================

    public List<DictCategory> listCategories(String orgId) {
        LambdaQueryWrapper<DictCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DictCategory::getOrganizationId, orgId);
        List<DictCategory> categories = dictCategoryMapper.selectListByLambda(wrapper);
        categories.sort(Comparator.comparingLong(DictCategory::getPos));
        return categories;
    }

    public void addCategory(DictCategoryAddRequest request, String userId, String orgId) {
        // 检查code唯一性
        LambdaQueryWrapper<DictCategory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DictCategory::getCode, request.getCode()).eq(DictCategory::getOrganizationId, orgId);
        List<DictCategory> existing = dictCategoryMapper.selectListByLambda(wrapper);
        if (!existing.isEmpty()) {
            throw new GenericException(Translator.get("dict_category_code_exists"));
        }

        DictCategory category = BeanUtils.copyBean(new DictCategory(), request);
        category.setId(IDGenerator.nextStr());
        category.setOrganizationId(orgId);
        category.setCreateUser(userId);
        category.setUpdateUser(userId);
        category.setCreateTime(System.currentTimeMillis());
        category.setUpdateTime(System.currentTimeMillis());
        if (category.getEnabled() == null) {
            category.setEnabled(true);
        }
        if (category.getPos() == null) {
            category.setPos(0L);
        }
        dictCategoryMapper.insert(category);
    }

    public void updateCategory(DictCategoryUpdateRequest request, String userId, String orgId) {
        DictCategory existing = dictCategoryMapper.selectByPrimaryKey(request.getId());
        if (existing == null) {
            throw new GenericException(Translator.get("dict_category_not_found"));
        }

        DictCategory category = BeanUtils.copyBean(new DictCategory(), request);
        category.setId(request.getId());
        category.setCode(existing.getCode()); // code不可修改
        category.setOrganizationId(orgId);
        category.setUpdateUser(userId);
        category.setUpdateTime(System.currentTimeMillis());
        // 保留原有的 createUser/createTime
        category.setCreateUser(existing.getCreateUser());
        category.setCreateTime(existing.getCreateTime());
        dictCategoryMapper.updateById(category);
    }

    public void deleteCategory(String id) {
        DictCategory existing = dictCategoryMapper.selectByPrimaryKey(id);
        if (existing == null) {
            throw new GenericException(Translator.get("dict_category_not_found"));
        }

        // 级联删除所有字典项
        LambdaQueryWrapper<DictItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DictItem::getCategoryId, id);
        dictItemMapper.deleteByLambda(wrapper);

        dictCategoryMapper.deleteByPrimaryKey(id);
    }

    // ==================== 字典项 ====================

    public List<DictItem> listItems(String categoryId) {
        LambdaQueryWrapper<DictItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(DictItem::getCategoryId, categoryId);
        List<DictItem> items = dictItemMapper.selectListByLambda(wrapper);
        items.sort(Comparator.comparingLong(DictItem::getPos));
        return items;
    }

    public List<DictItem> getItemsByCode(String code, String orgId) {
        // 先根据code查分类
        LambdaQueryWrapper<DictCategory> catWrapper = new LambdaQueryWrapper<>();
        catWrapper.eq(DictCategory::getCode, code).eq(DictCategory::getOrganizationId, orgId);
        List<DictCategory> categories = dictCategoryMapper.selectListByLambda(catWrapper);
        if (categories.isEmpty()) {
            return List.of();
        }
        return listItems(categories.get(0).getId());
    }

    public void addItem(DictItemAddRequest request, String userId) {
        // 验证分类存在
        DictCategory category = dictCategoryMapper.selectByPrimaryKey(request.getCategoryId());
        if (category == null) {
            throw new GenericException(Translator.get("dict_category_not_found"));
        }

        DictItem item = BeanUtils.copyBean(new DictItem(), request);
        item.setId(IDGenerator.nextStr());
        item.setCreateUser(userId);
        item.setUpdateUser(userId);
        item.setCreateTime(System.currentTimeMillis());
        item.setUpdateTime(System.currentTimeMillis());
        if (item.getEnabled() == null) {
            item.setEnabled(true);
        }
        if (item.getPos() == null) {
            item.setPos(0L);
        }
        dictItemMapper.insert(item);
    }

    public void updateItem(DictItemUpdateRequest request, String userId) {
        DictItem existing = dictItemMapper.selectByPrimaryKey(request.getId());
        if (existing == null) {
            throw new GenericException(Translator.get("dict_item_not_found"));
        }

        DictItem item = BeanUtils.copyBean(new DictItem(), request);
        item.setId(request.getId());
        item.setUpdateUser(userId);
        item.setUpdateTime(System.currentTimeMillis());
        // 保留原有的 createUser/createTime
        item.setCreateUser(existing.getCreateUser());
        item.setCreateTime(existing.getCreateTime());
        dictItemMapper.updateById(item);
    }

    public void deleteItem(String id) {
        DictItem existing = dictItemMapper.selectByPrimaryKey(id);
        if (existing == null) {
            throw new GenericException(Translator.get("dict_item_not_found"));
        }
        dictItemMapper.deleteByPrimaryKey(id);
    }
}

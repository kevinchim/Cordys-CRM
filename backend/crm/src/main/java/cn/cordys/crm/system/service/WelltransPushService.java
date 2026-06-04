package cn.cordys.crm.system.service;

import cn.cordys.common.uid.IDGenerator;
import cn.cordys.common.util.JSON;
import cn.cordys.crm.customer.domain.Customer;
import cn.cordys.crm.customer.domain.CustomerContact;
import cn.cordys.crm.customer.domain.CustomerContactField;
import cn.cordys.crm.system.domain.Parameter;
import cn.cordys.crm.system.domain.User;
import cn.cordys.crm.system.domain.WelltransPushLog;
import cn.cordys.crm.system.dto.WelltransCustomerDTO;
import cn.cordys.crm.system.dto.WelltransPushConfigDTO;
import cn.cordys.crm.system.dto.WelltransPushResultDTO;
import cn.cordys.mybatis.BaseMapper;
import cn.cordys.mybatis.lambda.LambdaQueryWrapper;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
@Slf4j
public class WelltransPushService {

    private static final String PARAM_API_URL = "welltrans.api.url";
    private static final String PARAM_API_KEY = "welltrans.api.key";
    private static final String PARAM_AUTO_PUSH = "welltrans.auto.push.enabled";
    private static final String PARAM_MANUAL_PUSH = "welltrans.manual.push.enabled";

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9()+\\-\\s]+$");

    private static final RestTemplate restTemplate;

    static {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(30000);
        factory.setReadTimeout(30000);
        restTemplate = new RestTemplate(factory);
    }

    @Resource
    private BaseMapper<Parameter> parameterMapper;

    @Resource
    private BaseMapper<Customer> customerMapper;

    @Resource
    private BaseMapper<CustomerContact> customerContactMapper;

    @Resource
    private BaseMapper<CustomerContactField> customerContactFieldMapper;

    @Resource
    private BaseMapper<WelltransPushLog> pushLogMapper;

    @Resource
    private BaseMapper<User> userMapper;

    /**
     * 获取推送配置
     */
    public WelltransPushConfigDTO getConfig() {
        WelltransPushConfigDTO config = new WelltransPushConfigDTO();
        config.setApiUrl(getParamValue(PARAM_API_URL));
        config.setApiKey(getParamValue(PARAM_API_KEY));
        config.setAutoPushEnabled(Boolean.parseBoolean(getParamValue(PARAM_AUTO_PUSH)));
        config.setManualPushEnabled(Boolean.parseBoolean(getParamValue(PARAM_MANUAL_PUSH)));
        return config;
    }

    /**
     * 保存推送配置
     */
    public void saveConfig(WelltransPushConfigDTO config) {
        saveParam(PARAM_API_URL, config.getApiUrl());
        saveParam(PARAM_API_KEY, config.getApiKey());
        saveParam(PARAM_AUTO_PUSH, String.valueOf(Boolean.TRUE.equals(config.getAutoPushEnabled())));
        saveParam(PARAM_MANUAL_PUSH, String.valueOf(Boolean.TRUE.equals(config.getManualPushEnabled())));
    }

    /**
     * 检查自动回收推送是否开启
     */
    public boolean isAutoPushEnabled() {
        return Boolean.parseBoolean(getParamValue(PARAM_AUTO_PUSH));
    }

    /**
     * 检查手动回收推送是否开启
     */
    public boolean isManualPushEnabled() {
        return Boolean.parseBoolean(getParamValue(PARAM_MANUAL_PUSH));
    }

    /**
     * 推送所有有归属的客户数据到 Welltrans API
     *
     * @param triggerType 触发类型: AUTO / MANUAL
     * @param orgId       组织ID
     * @param userId      操作用户ID
     */
    public WelltransPushResultDTO pushAllOwnedCustomers(String triggerType, String orgId, String userId) {
        WelltransPushConfigDTO config = getConfig();
        if (StringUtils.isBlank(config.getApiUrl()) || StringUtils.isBlank(config.getApiKey())) {
            log.warn("Welltrans推送配置不完整，跳过推送");
            return WelltransPushResultDTO.builder()
                    .success(false)
                    .errorMessage("推送配置不完整：API地址或API Key未设置")
                    .build();
        }

        // 查询所有有归属且不在公海的客户
        List<Customer> customers = getOwnedCustomers();
        if (CollectionUtils.isEmpty(customers)) {
            log.info("没有有归属的客户需要推送");
            return WelltransPushResultDTO.builder()
                    .success(true)
                    .totalCount(0)
                    .successCount(0)
                    .failCount(0)
                    .message("没有有归属的客户")
                    .build();
        }

        // 提取客户联系信息并构建推送数据
        List<WelltransCustomerDTO> pushData = buildPushData(customers);
        if (CollectionUtils.isEmpty(pushData)) {
            log.info("没有可推送的客户联系数据");
            return WelltransPushResultDTO.builder()
                    .success(true)
                    .totalCount(0)
                    .successCount(0)
                    .failCount(0)
                    .message("没有可推送的客户联系数据")
                    .build();
        }

        // 发送到 Welltrans API
        WelltransPushResultDTO result = sendToWelltransApi(config.getApiUrl(), config.getApiKey(), pushData);

        // 记录推送日志
        savePushLog(triggerType, orgId, userId, pushData.size(), result);

        return result;
    }

    /**
     * 查询所有有归属且不在公海的客户
     */
    private List<Customer> getOwnedCustomers() {
        LambdaQueryWrapper<Customer> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Customer::getInSharedPool, false);
        List<Customer> customers = customerMapper.selectListByLambda(wrapper);
        // 过滤掉没有归属的客户（owner为null的已在公海的客户）
        return customers.stream()
                .filter(c -> c.getOwner() != null)
                .collect(Collectors.toList());
    }

    /**
     * 根据客户列表构建推送数据
     */
    private List<WelltransCustomerDTO> buildPushData(List<Customer> customers) {
        List<WelltransCustomerDTO> result = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        // 收集所有客户ID
        List<String> customerIds = customers.stream().map(Customer::getId).toList();

        // 查询所有相关联系人
        LambdaQueryWrapper<CustomerContact> contactWrapper = new LambdaQueryWrapper<>();
        contactWrapper.in(CustomerContact::getCustomerId, customerIds);
        List<CustomerContact> contacts = customerContactMapper.selectListByLambda(contactWrapper);

        // 查询联系人的自定义字段（邮箱存储在 customer_contact_field 表）
        List<String> contactIds = contacts.stream().map(CustomerContact::getId).toList();
        Map<String, List<String>> emailByContactId = Collections.emptyMap();
        if (CollectionUtils.isNotEmpty(contactIds)) {
            LambdaQueryWrapper<CustomerContactField> fieldWrapper = new LambdaQueryWrapper<>();
            fieldWrapper.in(CustomerContactField::getResourceId, contactIds);
            List<CustomerContactField> fields = customerContactFieldMapper.selectListByLambda(fieldWrapper);
            emailByContactId = fields.stream()
                    .filter(f -> f.getFieldValue() instanceof String s && s.contains("@"))
                    .collect(Collectors.groupingBy(
                            CustomerContactField::getResourceId,
                            Collectors.mapping(f -> ((String) f.getFieldValue()).trim(), Collectors.toList())
                    ));
        }

        // 按客户ID分组联系人
        Map<String, List<CustomerContact>> contactsByCustomer = contacts.stream()
                .collect(Collectors.groupingBy(CustomerContact::getCustomerId));

        // 构建 owner ID → 用户姓名 映射
        List<String> ownerIds = customers.stream().map(Customer::getOwner).distinct().toList();
        Map<String, String> ownerNameMap = buildOwnerNameMap(ownerIds);

        for (Customer customer : customers) {
            String salesName = ownerNameMap.getOrDefault(customer.getOwner(), customer.getOwner());
            List<CustomerContact> customerContacts = contactsByCustomer.getOrDefault(customer.getId(), Collections.emptyList());
            for (CustomerContact contact : customerContacts) {
                List<String> values = extractContactValues(contact, emailByContactId);
                for (String value : values) {
                    int type = detectType(value);
                    int isFullEmail = (type == 1 && EMAIL_PATTERN.matcher(value).matches()) ? 1 : 0;

                    WelltransCustomerDTO dto = WelltransCustomerDTO.builder()
                            .email(value)
                            .sales(salesName)
                            .type(type)
                            .iscooperated(0)
                            .isfullemailaddress(isFullEmail)
                            .createDate(customer.getCreateTime() != null ? sdf.format(new Date(customer.getCreateTime())) : sdf.format(new Date()))
                            .build();
                    result.add(dto);
                }
            }
        }
        return result;
    }

    /**
     * 构建 owner ID → 用户姓名 映射
     */
    private Map<String, String> buildOwnerNameMap(List<String> ownerIds) {
        Map<String, String> map = new java.util.HashMap<>();
        if (CollectionUtils.isEmpty(ownerIds)) {
            return map;
        }
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.in(User::getId, ownerIds);
        List<User> users = userMapper.selectListByLambda(wrapper);
        for (User user : users) {
            map.put(user.getId(), user.getName());
        }
        return map;
    }

    /**
     * 从联系人中提取联系方式（电话和邮箱各自作为独立记录）
     */
    private List<String> extractContactValues(CustomerContact contact, Map<String, List<String>> emailByContactId) {
        List<String> values = new ArrayList<>();
        // 电话
        if (StringUtils.isNotBlank(contact.getPhone())) {
            values.add(contact.getPhone().trim());
        }
        // 邮箱：从 customer_contact_field 自定义字段中获取
        List<String> emails = emailByContactId.get(contact.getId());
        if (CollectionUtils.isNotEmpty(emails)) {
            values.addAll(emails);
        }
        return values;
    }

    /**
     * 检测联系方式类型：0=电话, 1=邮箱
     */
    private int detectType(String value) {
        if (value == null) return 0;
        // 纯数字或含+()- 空格 → 电话
        if (PHONE_PATTERN.matcher(value).matches() && value.replaceAll("[0-9]", "").length() < value.length()) {
            return 0;
        }
        // 含@ → 邮箱
        if (value.contains("@")) {
            return 1;
        }
        return 0;
    }

    /**
     * 发送数据到 Welltrans API
     */
    private WelltransPushResultDTO sendToWelltransApi(String apiUrl, String apiKey, List<WelltransCustomerDTO> customers) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("X-CRM-Api-Key", apiKey);

            Map<String, Object> body = Map.of("customers", customers);
            HttpEntity<Map<String, Object>> requestEntity = new HttpEntity<>(body, headers);

            log.info("推送客户数据到 Welltrans API, 数量: {}", customers.size());
            var response = restTemplate.postForEntity(apiUrl, requestEntity, String.class);

            String responseBody = response.getBody();
            log.info("Welltrans API 响应: {}", responseBody);

            if (response.getStatusCode().is2xxSuccessful() && StringUtils.isNotBlank(responseBody)) {
                @SuppressWarnings("unchecked")
                Map<String, Object> responseMap = JSON.parseObject(responseBody, Map.class);
                Boolean success = (Boolean) responseMap.get("success");
                if (Boolean.TRUE.equals(success)) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> data = (Map<String, Object>) responseMap.get("data");
                    int inserted = data != null && data.get("inserted") != null ? ((Number) data.get("inserted")).intValue() : customers.size();
                    int invalid = data != null && data.get("invalid") != null ? ((Number) data.get("invalid")).intValue() : 0;
                    @SuppressWarnings("unchecked")
                    List<String> warnings = data != null ? (List<String>) data.get("warnings") : Collections.emptyList();
                    return WelltransPushResultDTO.builder()
                            .success(true)
                            .totalCount(customers.size())
                            .successCount(inserted)
                            .failCount(invalid)
                            .message((String) responseMap.get("message"))
                            .warnings(warnings)
                            .build();
                } else {
                    return WelltransPushResultDTO.builder()
                            .success(false)
                            .totalCount(customers.size())
                            .successCount(0)
                            .failCount(customers.size())
                            .message((String) responseMap.get("message"))
                            .errorMessage((String) responseMap.get("message"))
                            .build();
                }
            }
            return WelltransPushResultDTO.builder()
                    .success(false)
                    .totalCount(customers.size())
                    .successCount(0)
                    .failCount(customers.size())
                    .errorMessage("API响应异常: " + response.getStatusCode())
                    .build();
        } catch (Exception e) {
            log.error("推送客户数据到 Welltrans API 失败", e);
            return WelltransPushResultDTO.builder()
                    .success(false)
                    .totalCount(customers.size())
                    .successCount(0)
                    .failCount(customers.size())
                    .errorMessage("推送失败: " + e.getMessage())
                    .build();
        }
    }

    /**
     * 保存推送日志
     */
    private void savePushLog(String triggerType, String orgId, String userId, int totalCount, WelltransPushResultDTO result) {
        WelltransPushLog pushLog = new WelltransPushLog();
        pushLog.setId(IDGenerator.nextStr());
        pushLog.setOrganizationId(orgId);
        pushLog.setTriggerType(triggerType);
        pushLog.setTotalCount(totalCount);
        pushLog.setSuccessCount(result.getSuccessCount() != null ? result.getSuccessCount() : 0);
        pushLog.setFailCount(result.getFailCount() != null ? result.getFailCount() : 0);
        pushLog.setResponseBody(JSON.toJSONString(result));
        pushLog.setErrorMessage(result.getErrorMessage());
        pushLog.setCreateTime(System.currentTimeMillis());
        pushLog.setUpdateTime(System.currentTimeMillis());
        pushLog.setCreateUser(userId);
        pushLog.setUpdateUser(userId);
        pushLogMapper.insert(pushLog);
    }

    /**
     * 查询推送日志
     */
    public List<WelltransPushLog> getPushLogs() {
        LambdaQueryWrapper<WelltransPushLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(WelltransPushLog::getCreateTime);
        return pushLogMapper.selectListByLambda(wrapper);
    }

    private String getParamValue(String key) {
        LambdaQueryWrapper<Parameter> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Parameter::getParamKey, key);
        List<Parameter> params = parameterMapper.selectListByLambda(wrapper);
        return CollectionUtils.isEmpty(params) ? null : params.get(0).getParamValue();
    }

    private void saveParam(String key, String value) {
        if (value == null) {
            return;
        }
        LambdaQueryWrapper<Parameter> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Parameter::getParamKey, key);
        List<Parameter> params = parameterMapper.selectListByLambda(wrapper);
        if (CollectionUtils.isEmpty(params)) {
            Parameter param = new Parameter();
            param.setParamKey(key);
            param.setParamValue(value);
            param.setType("text");
            parameterMapper.insert(param);
        } else {
            // sys_parameter 表主键是 param_key，不能用 updateById（它会按 id 列匹配）
            parameterMapper.deleteByLambda(wrapper);
            Parameter param = new Parameter();
            param.setParamKey(key);
            param.setParamValue(value);
            param.setType("text");
            parameterMapper.insert(param);
        }
    }
}

package cn.cordys.crm.system.controller;

import cn.cordys.common.constants.PermissionConstants;
import cn.cordys.context.OrganizationContext;
import cn.cordys.crm.system.domain.WelltransPushLog;
import cn.cordys.crm.system.dto.WelltransPushConfigDTO;
import cn.cordys.crm.system.dto.WelltransPushResultDTO;
import cn.cordys.crm.system.service.WelltransPushService;
import cn.cordys.security.SessionUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.apache.shiro.authz.annotation.RequiresPermissions;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/welltrans-push")
@Tag(name = "Welltrans CRM API推送")
public class WelltransPushController {

    @Resource
    private WelltransPushService welltransPushService;

    @GetMapping("/config")
    @Operation(summary = "获取推送配置")
    @RequiresPermissions(value = {PermissionConstants.SYSTEM_SETTING_READ})
    public WelltransPushConfigDTO getConfig() {
        return welltransPushService.getConfig();
    }

    @PostMapping("/config")
    @Operation(summary = "保存推送配置")
    @RequiresPermissions(value = {PermissionConstants.SYSTEM_SETTING_UPDATE})
    public void saveConfig(@RequestBody WelltransPushConfigDTO config) {
        welltransPushService.saveConfig(config);
    }

    @PostMapping("/execute")
    @Operation(summary = "立即执行推送")
    @RequiresPermissions(value = {PermissionConstants.SYSTEM_SETTING_UPDATE})
    public WelltransPushResultDTO execute() {
        return welltransPushService.pushAllOwnedCustomers(
                "MANUAL",
                OrganizationContext.getOrganizationId(),
                SessionUtils.getUserId()
        );
    }

    @GetMapping("/logs")
    @Operation(summary = "获取推送日志")
    @RequiresPermissions(value = {PermissionConstants.SYSTEM_SETTING_READ})
    public List<WelltransPushLog> getLogs() {
        return welltransPushService.getPushLogs();
    }
}

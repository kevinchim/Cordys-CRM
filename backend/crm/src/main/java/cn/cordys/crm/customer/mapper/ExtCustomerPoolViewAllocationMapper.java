package cn.cordys.crm.customer.mapper;

import cn.cordys.crm.customer.domain.CustomerPoolViewAllocation;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ExtCustomerPoolViewAllocationMapper {

    List<String> selectAllocatedCustomerIds(@Param("poolId") String poolId, @Param("userId") String userId,
                                            @Param("periodType") String periodType, @Param("periodKey") String periodKey);

    List<String> selectAllocatedCustomerIdsExcludePicked(@Param("poolId") String poolId, @Param("userId") String userId,
                                                          @Param("periodType") String periodType, @Param("periodKey") String periodKey,
                                                          @Param("ownerIds") List<String> ownerIds);

    int deleteByPeriod(@Param("poolId") String poolId, @Param("userId") String userId,
                       @Param("periodType") String periodType, @Param("periodKey") String periodKey);

    List<String> selectCustomerIdsExcludeAllocated(@Param("poolId") String poolId,
                                                    @Param("periodType") String periodType, @Param("periodKey") String periodKey,
                                                    @Param("ownerIds") List<String> ownerIds);
}

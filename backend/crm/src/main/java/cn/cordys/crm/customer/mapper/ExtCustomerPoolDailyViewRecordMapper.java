package cn.cordys.crm.customer.mapper;

import cn.cordys.crm.customer.domain.CustomerPoolDailyViewRecord;
import org.apache.ibatis.annotations.Param;

import java.util.List;

public interface ExtCustomerPoolDailyViewRecordMapper {

    int countTodayViews(@Param("poolId") String poolId, @Param("userId") String userId,
                        @Param("startOfDay") long startOfDay, @Param("endOfDay") long endOfDay);

    List<CustomerPoolDailyViewRecord> selectTodayViews(@Param("poolId") String poolId, @Param("userId") String userId,
                                                       @Param("startOfDay") long startOfDay, @Param("endOfDay") long endOfDay);
}

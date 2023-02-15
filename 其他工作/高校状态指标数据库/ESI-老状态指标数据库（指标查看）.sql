# 高校状态指标数据库指标查看页面数据：

USE ub_details_raw;
SET @rowNum = 0;
SELECT (@rowNum := @rowNum + 1)                        AS id,
       issue_year,
       issue_time,
       school_code_ranking                             AS institutionCode,
       institution_cn                                  AS school_name,
       subject_name_cn                                 AS ESI_subject_name,
       ranking,
       enter_subject_no,
       LEFT(issue_year, 4)                             AS data_year,
       NULL                                               remark1,
       NOW()                                           AS crt_time,
       'system'                                        AS crt_user,
       IF(is_one_thounds = 1, RIGHT(issue_year, 2), 0) AS is_one_thounds,
       IF(is_one_million = 1, RIGHT(issue_year, 2), 0) AS is_one_million,
       RIGHT(issue_year, 2)                            AS data_month
FROM `esi_basics_data`
WHERE school_code_ranking IS NOT NULL
  AND school_code_ranking != ''
  AND subject_name_cn != '整体'
  AND issue_time = (SELECT MAX(issue_time) FROM esi_count_data);

# 高校状态指标数据库国际对比页面数据：

-- todo 根据数据发布版本月份修改： indicatorCode、indicatorCodeSub：'5_3', 'r1_3','r1_3_top10000' ,'r1_3_top1000'
/*
r1_0	ESI前1%学科数（1月）
r1_1	ESI前1%学科数（3月）
r1_2	ESI前1%学科数（5月）
r1_3	ESI前1%学科数（7月）
r1_4	ESI前1%学科数（9月）
r1_5	ESI前1%学科数（11月）
r1_0	ESI前1‰学科数（1月）
r1_1	ESI前1‰学科数（3月）
r1_2	ESI前1‰学科数（5月）
r1_3	ESI前1‰学科数（7月）
r1_4	ESI前1‰学科数（9月）
r1_5	ESI前1‰学科数（11月）
r1_0	ESI前1‱学科数（1月）
r1_1	ESI前1‱学科数（3月）
r1_2	ESI前1‱学科数（5月）
r1_3	ESI前1‱学科数（7月）
r1_4	ESI前1‱学科数（9月）
r1_5	ESI前1‱学科数（11月）
5_0	    ESI综合被引次数排名（1月）
5_1	    ESI综合被引次数排名（3月）
5_2	    ESI综合被引次数排名（5月）
5_3	    ESI综合被引次数排名（7月）
5_4	    ESI综合被引次数排名（9月）
5_5	    ESI综合被引次数排名（11月）
*/

USE ub_details_raw;
SELECT id,
       school_code_world                            AS institutionCode,
       institution_cn                               AS institutionName,
       IF(subject_name_en = 'Total', '5_0', 'r1_0') AS indicatorCode, -- todo
       subject_name_en                              AS indicatorSubName,
       issue_year                                   AS real_year,
       LEFT(issue_time, 4)                          AS data_year,
       ranking                                      AS indicatorValue,
       enter_subject_no                             AS totalInstitution,
       is_one_thounds                               AS isTop1000,
       is_one_million                               AS isTop10000,
       cites                                        AS esiTotalCites,
       NULL                                            awardee,
       NULL                                            awardName,
       NULL                                            levelCode,
       NULL                                            subjectCode,
       CASE
           WHEN is_one_million = 1 AND subject_name_en != 'Total' THEN 'r1_0_top10000'  -- todo
           WHEN is_one_thounds = 1 AND is_one_million = 0 AND subject_name_en != 'Total' THEN 'r1_0_top1000'  -- todo
           ELSE NULL END                            AS indicatorCodeSub,
       crt_time
FROM esi_basics_data
WHERE school_code_world IS NOT NULL
  AND school_code_world != ''
  AND issue_time = (SELECT MAX(issue_time) FROM esi_count_data);
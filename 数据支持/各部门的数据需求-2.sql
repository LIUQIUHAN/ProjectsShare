# USE ub_ranking_0520;

# 指标层面
/*SELECT -- id,
       -- pid,
       mod_code                                                                                  模块代码,
       mod_name                                                                                  模块名称,
       dim_code                                                                                  维度代码,
       dim_name                                                                                  维度名称,
       `code`                                                                                    指标代码,
       `name`                                                                                    指标名称,
       abbr                                                                                      指标简称,
       detail_target_ver                                                                         默认监测年份,
       detail_avail_ver                                                                          指标年份范围,
       IF(val_unit_code IS NULL, 'zhehe/bizhi', val_unit_code)                                   指标单位,
       IF(var_codes IS NULL, val_formula_codes, var_codes)                                       变量代码集,
       IF(var_names IS NULL, val_formula_desc, var_names)                                        `变量名称集/公式`,
       detail_access_rule                                                                        计算类型（包含了去重规则）,
       IF(is_full_sample = 0, '否', '是')                                                          是否全样本,
       val_alt_group                                                                             替代值计算分组,
       val_alt_use                                                                               替代值取值,
       (CASE WHEN ind_lev = - 5 THEN '弃用指标' WHEN ind_lev = 8 THEN '排名指标' ELSE '参考指标' END)        指标类型,
       (CASE WHEN (ind_lev = - 5 OR ind_lev = 2 OR ind_lev = 6 OR ind_lev = 8) THEN '核心指标'
             WHEN ind_lev = 0 THEN '非核心指标'
             ELSE '非核心指标' END)                                                                   关联页面,-- -5=弃用指标，2=核心指标，6=排名推演页面可能显示，8=可能是排名指标；这里说「可能」的原因是不同排名类型下，指标的权重可能不同，比如判断是否排名指标 is_rank = (ind_lev>=8 && r_type_ind_weight>0)
       (CASE WHEN shows = '' THEN '对客户开放' WHEN shows = '^' THEN '不对客户开放' ELSE '根据排名类型对客户开放' END) 是否开放,-- 显示条件；空代表总是显示；`^`代表总是不显示；`^1,3`表示仅排名类型 1,3 隐藏(其余显示)；`2`表示仅对排名类型 2 显示(其余隐藏)；后端过滤好数据给前端，前端不需要了解
       definition                                                                                指标定义
FROM v_ind_lat_l3_flat_wide;*/

# 变量层面
/*SELECT -- id,
       -- pid,
       ind_code           指标代码,
       ind_name           指标名称,
       code               变量代码,
       name               变量名称,
       detail_target_ver  默认监测年份,
       detail_avail_ver   变量年份范围,
       detail_ver_rule    变量取值规则,
       detail_sources     变量来源优先级,
       detail_access_rule 计算类型（包含了去重规则）,
       detail_filter      变量过滤条件,
       detail_weight      变量权重
FROM v_ind_lat_l4_flat_wide;*/

# 数据源层面
/*SELECT A.ind_code 指标代码, B.name 指标名称, A.name 来源名称, A._new_src_id 新平台来源ID, A._old_src_id 老平台来源ID
FROM c_ind_source               A
     LEFT JOIN indicator_latest B ON A.ind_code = B.code
WHERE B.name IS NOT NULL
  AND A._new_src_id IS NOT NULL;*/


# 学科平台维度、指标、编辑监测年份数据
USE spm_ranking_dev;
SELECT id,
       pid,
       r_root_id,
       IF(r_root_id = 1, '学科排名', '学科评估') page,
       name,
       code,
       level,
       detail ->> '$.targetVer'          targetVer,
       detail ->> '$.availVer'           availVer,
       val ->> '$.incVer'                incVer,
       definition
FROM spm_ranking_dev.indicator
WHERE r_ver_no = 202302 AND deleted_at IS NULL
ORDER BY r_root_id, level, ord_no;

SELECT id,
       pid,
       -1                    AS   r_root_id,
       '全部指标'                   page,
       name,
       code,
       level,
       detail ->> '$.targetVer' targetVer,
       detail ->> '$.availVer'  availVer,
       definition
FROM spm_ranking_dev.indicator_latest
WHERE deleted_at IS NULL
ORDER BY r_root_id, level, ord_no;


SELECT id,
       pid,
       r_root_id,
       '博士点申报'                  page,
       name,
       code,
       level,
       detail ->> '$.targetVer' targetVer,
       detail ->> '$.availVer'  availVer,
       NULL                     incVer,
       definition
FROM dpa_ranking_dev.dpa_ranking_ind
WHERE r_ver_no = 202303 AND deleted_at IS NULL
ORDER BY r_root_id, level, ord_no;


# 360平台维度、指标、编辑监测年份数据
SELECT id,
       pid,
       '指标大全' AS                page,
       code,
       name,
       level,
       detail ->> '$.availVer'  availVer,
       detail ->> '$.targetVer' targetVer,
       definition
FROM ub_ranking_dev.indicator_latest
WHERE level > 2 AND deleted_at IS NULL
ORDER BY level, ord_no, name;


# 专业平台指标信息
SELECT id,
       pid,
       name,
       code,
       level,
       weight,
       definition,
       ind_ver_range,
       detail_ver_start,
       detail_ver_end
FROM mpm_ranking_dev.indicator
WHERE ranking_ver_no = 202301
  AND level IN (3, 4)
  AND centrality != - 1
ORDER BY level, ord_no;








# 学科平台变量明细统计情况
USE spm_ranking_dev;

WITH XY AS (
    SELECT A.var_code, B.name, COUNT(*) coxy
    FROM spm_details_0208.var_detail A
             LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
    WHERE A._eversions_ = '202302' AND deleted_at IS NULL
    GROUP BY A.var_code),
     GX AS (
         SELECT A.var_code, B.name, COUNT(*) cogx, COUNT(DISTINCT univ_code) gx
         FROM spm_details_0208.var_detail A
                  LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
         WHERE A._eversions_ = '202302'
           AND univ_code != 'XXXXX'
           AND univ_code RLIKE 'RC'
           AND subj_code != ''
         GROUP BY A.var_code),
     YR AS (
         SELECT A.var_code, B.name, MIN(ver_no) MI, MAX(ver_no) MA
         FROM spm_details_0208.var_detail A
                  LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
         WHERE A._eversions_ = '202302'
           AND A.ver_no != 0
           AND A.agg_from = 0
         GROUP BY A.var_code)
SELECT XY.var_code 变量代码,
       XY.name     变量名称,
       XY.coxy     变量现有明细记录总数,
       GX.cogx     变量有效记录数,
       GX.gx       变量的明细记录覆盖的高校数,
       YR.MI       最早年份,
       YR.MA       最新年份
FROM XY
         LEFT JOIN GX USING (var_code)
         LEFT JOIN YR USING (var_code);

# 360平台变量明细统计情况
WITH XY AS (
    SELECT A.var_code, B.name, COUNT(*) coxy
    FROM ub_details_0429.var_detail A
             LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
    WHERE A._r_ver_no IN (202302, 0)  AND deleted_at IS NULL
    GROUP BY A.var_code),
     GX AS (
         SELECT A.var_code, B.name, COUNT(*) cogx, COUNT(DISTINCT univ_code) gx
         FROM ub_details_0429.var_detail A
                  LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
         WHERE A._r_ver_no IN (202302, 0)
           AND univ_code != 'XXXXX'
           AND univ_code RLIKE 'RC'
         GROUP BY A.var_code),
     YR AS (
         SELECT A.var_code, B.name, MIN(ver_no) MI, MAX(ver_no) MA
         FROM ub_details_0429.var_detail A
                  LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
         WHERE A._r_ver_no IN (202302, 0)
         GROUP BY A.var_code)
SELECT XY.var_code 变量代码,
       XY.name     变量名称,
       XY.coxy     变量现有明细记录总数,
       GX.cogx     变量有效记录数,
       GX.gx       变量的明细记录覆盖的高校数,
       YR.MI       最早年份,
       YR.MA       最新年份
FROM XY
         LEFT JOIN GX USING (var_code)
         LEFT JOIN YR USING (var_code);





# 360变量明细库中各变量最新年份
SELECT A.var_code,
       B.name,
       MAX(A.ver_no) max_yr,
       MIN(A.ver_no) min_yr
FROM ub_details_0429.var_detail A
         JOIN ub_details_0429.variable B ON A.var_code = B.code
WHERE A._r_ver_no = 202301
GROUP BY A.var_code
UNION ALL
SELECT A.var_code,
       B.name,
       MAX(A.ver_no) max_yr,
       MIN(A.ver_no) min_yr
FROM ub_details_0429.var_detail A
         JOIN ub_details_0429.variable B ON A.var_code = B.code
WHERE A._r_ver_no = 0
GROUP BY A.var_code;






# 近期在和程老师讨论大学360「发展速度」功能设计时，程老师提到需要将360平台中所有变量的数据覆盖情况拉出来，以此来判断哪些变量可以进入功能设计：
# 360平台
WITH XY AS (
    SELECT A.var_code,ver_no, B.name, COUNT(*) coxy
    FROM ub_details_0429.var_detail A
             LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
    WHERE A._r_ver_no IN (202302, 0)  AND deleted_at IS NULL
    GROUP BY A.var_code,ver_no),
     GX AS (
         SELECT A.var_code,ver_no, B.name, COUNT(*) cogx, COUNT(DISTINCT univ_code) gx
         FROM ub_details_0429.var_detail A
                  LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
         WHERE A._r_ver_no IN (202302, 0)
           AND univ_code != 'XXXXX'
           AND univ_code RLIKE 'RC'
         GROUP BY A.var_code,ver_no),
     YR AS (
         SELECT A.var_code, B.name, MIN(ver_no) MI, MAX(ver_no) MA
         FROM ub_details_0429.var_detail A
                  LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
         WHERE A._r_ver_no IN (202302, 0)
         GROUP BY A.var_code)
SELECT XY.var_code 变量代码,
       XY.name     变量名称,
       XY.ver_no   年份,
       XY.coxy     变量现有明细记录总数,
       GX.cogx     变量有效记录数,
       GX.gx       变量的明细记录覆盖的高校数,
       YR.MI       最早年份,
       YR.MA       最新年份
FROM XY
         LEFT JOIN GX USING (var_code,ver_no)
         LEFT JOIN YR USING (var_code)
ORDER BY 变量代码,年份;



# 学科平台
WITH XY AS (
    SELECT A.var_code,ver_no, B.name, COUNT(*) coxy
    FROM spm_details_0208.var_detail A
             LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
    WHERE A._eversions_ = '202302'  AND deleted_at IS NULL
    GROUP BY A.var_code,ver_no),
     GX AS (
         SELECT A.var_code,ver_no, B.name, COUNT(*) cogx, COUNT(DISTINCT univ_code) gx
         FROM spm_details_0208.var_detail A
                  LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
         WHERE A._eversions_ = '202302'
           AND univ_code != 'XXXXX'
           AND univ_code RLIKE 'RC'
         GROUP BY A.var_code,ver_no),
     YR AS (
         SELECT A.var_code, B.name, MIN(ver_no) MI, MAX(ver_no) MA
         FROM spm_details_0208.var_detail A
                  LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
         WHERE A._eversions_ = '202302'
         GROUP BY A.var_code)
SELECT XY.var_code 变量代码,
       XY.name     变量名称,
       XY.ver_no   年份,
       XY.coxy     变量现有明细记录总数,
       GX.cogx     变量有效记录数,
       GX.gx       变量的明细记录覆盖的高校数,
       YR.MI       最早年份,
       YR.MA       最新年份
FROM XY
         LEFT JOIN GX USING (var_code,ver_no)
         LEFT JOIN YR USING (var_code)
ORDER BY 变量代码,年份;



# 专业平台变量明细年份统计
SELECT var_id                                                                      变量ID,
       (SELECT DISTINCT name FROM mpm_ranking_dev.ind_var B WHERE A.var_id = B.id) 变量名称,
       MIN(A.ver_no)                                                               最早年份,
       MAX(A.ver_no)                                                               最新年份,
       GROUP_CONCAT(DISTINCT A.ver_no)                                             有数据年份
FROM mpm_ranking_dev.ind_var_detail A
WHERE deleted_at IS NULL
GROUP BY A.var_id;


SELECT var_id                                                                        变量ID,
       (SELECT DISTINCT B.code FROM mpm_ranking_dev.ind_var B WHERE A.var_id = B.id) 变量代码,
       (SELECT DISTINCT B.name FROM mpm_ranking_dev.ind_var B WHERE A.var_id = B.id) 变量名称,
       src_name                                                                      来源名称
FROM mpm_ranking_dev.ind_var_detail A
WHERE deleted_at IS NULL
  AND src_name != ''
GROUP BY A.var_id, A.src_name
ORDER BY A.var_id;





























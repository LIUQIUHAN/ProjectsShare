USE ub_details_raw;

# 注意事项：
# 1.数据入库前检查本次更新变量所在业务库中的存储格式（版本、字段内容、数据类型、字段是否为空、学校代码是否为XXXXX、奖项等级、detail等），并根据其格式更新模板
# 2.科睿唯安高被引科学家：360平台/状态指标数据库按当选计算，学科平台按现职计算
# 3.360平台和学科平台变量明细表var_detail中：lev、val字段为0或为1
# 4.360平台、状态指标数据库、学科平台相同变量名称存在变量代码不同的情况
# 5.客户反馈数据更新时需注意是更新还是新增
# 6.数据入临时库注意备注信息（含数据团队的备注和页面显示的备注-可能存在需要拼接的情况）
# 7.爱思唯尔和科睿唯安更新指标信息是需注意更新indcator.detail.targetVerLast
# 8.detail-json中除了boring_year和dead_year为数值类型外，其余的关于年份的均存为字符串（eg："2010"、"2010.12"、"2010.12.25"、"早于2019年"）
# 9.360平台 马工程教材：detail中project_name需合并教材名称和人才姓名（eg："宪法学（第二版）（胡云腾）"），学科平台不用做此处理
# 10.tetail中project_money保留整数
# 11.项目金额为估算值时保留整数
# 12.学科平台更新造就学术人才时，需将人才获得最新头衔的年份提取出来作为ver_no
# 13.360平台更新不带版本熟悉的变量时需匹配学校、变量、来源、年份是否唯一，如唯一则新增，不唯一则替换更新
# 14.ESI数据需更新至多个数据库：360、学科、排名库
# 15.省级青年科技奖只需更新360平台（截至2023.01.06）
# 16.360平台更新或新增现职类的变量数据时需要更新detail.update_date(使用指标层面的截至年月：2012.12)，学科平台暂不处理
# 17.无项目金额时detail.project_money存null







# 现阶段变量入库模板：
# 360平台：奖项项目基地等
/*INSERT INTO ub_details_0429.var_detail (revision, var_id, var_code, source_id, ver_no, univ_code, lev, val,
                                        detail, subject_code, rel_code, agg_from, _eversions_, _r_ver_no,
                                        created_at, created_by, updated_at)
SELECT 0                          AS revision,
       B.var_id,
       A.var_code_360             AS var_code,
       B.source_id,
       A.yr                       AS ver_no,
       A.univ_code                AS univ_code,
       IFNULL(A.lev_360, 0)       AS lev,
       IFNULL(A.val, 1)           AS val,
       JSON_OBJECT(
               'remark1', NULL,  -- todo
               'remark2', NULL,  -- todo
               'born_year', NULL,
               'dead_year', NULL,
               'effective', '1',
               'award_level', A.lev_name,
               'talent_name', A.talent_name,
               'current_code', NULL,
               'current_name', NULL,
               'elected_code', A.univ_code,
               'elected_name', A.univ_name,
               'elected_year', CONCAT(A.yr),
               'project_name', A.project_name,
               'project_money', IFNULL(ROUND(A.val, 1), NULL),
               'val_display_suffix', IF(A.val_display_suffix = 1, '（估）', '')
           )                      AS detail,
       IFNULL(A.subject_code, '') AS subject_code,
       IFNULL(A.talent_code, '')  AS rel_code,
       0                          AS agg_from,
       '100000'                   AS _eversions_,  -- todo
       100000                     AS _r_ver_no,  -- todo
       A.create_time              AS create_time,
       -1                         AS created_by,
       A.create_time              AS updated_at
FROM updated_data_template_1_20221205 A  -- todo
         JOIN ub_details_0429.var_rel_source B ON A.var_code_360 = B.var_code
WHERE A.is_add = 1;*/


# 360平台：人才
/*INSERT INTO ub_details_0429.var_detail (revision, var_id, var_code, source_id, ver_no, univ_code, lev, val,
                                        detail, subject_code, rel_code, agg_from, _eversions_, _r_ver_no,
                                        created_at, created_by, updated_at)
SELECT 0                          AS revision,
       B.var_id,
       A.var_code_360             AS var_code,
       B.source_id,
       A.yr                       AS ver_no,
       A.univ_code,
       0                          AS lev,
       1                          AS val,
       JSON_OBJECT(
               'remark1', A.remark1, -- todo
               'remark2', A.remark2, -- todo
               'remark3', A.remark3, -- todo
               'born_year', A.born_year,
               'dead_year', A.dead_year,
               'effective', '',
               'award_level', NULL,
               'talent_name', A.talent_name,
               'current_code', A.current_code,
               'current_name', A.current_name,
               'elected_code', A.elected_code,
               'elected_name', A.elected_name,
               'elected_year', CONCAT(A.yr),
               'update_date', '', -- todo
               'is_canceled', IF((A.canceled_at = '' OR A.canceled_at IS NOT NULL), 1, 0),
               'canceled_at', A.canceled_at,
               'project_name', NULL,
               'project_money', NULL
           )                      AS detail,
       IFNULL(A.subject_code, '') AS subject_code,
       IFNULL(A.talent_code, '')  AS rel_code,
       0                          AS agg_from,
       '100000'                   AS _eversions_, -- todo
       100000                     AS _r_ver_no,   -- todo
       A.create_time              AS create_time,
       -1                         AS created_by,
       A.create_time              AS updated_at
FROM updated_data_template_2_20230215 A -- todo
         JOIN ub_details_0429.var_rel_source B ON A.var_code_360 = B.var_code
WHERE A.is_add = 1;*/






# 学科平台：奖项项目基地等
/*INSERT INTO spm_details_0208.var_detail (revision, var_id, var_code, source_id, ver_no, univ_code, lev, val,
                                         detail, subj_code, talent_code, talent_name, agg_from, _eversions_, _r_ver_no,
                                         created_at, created_by, updated_at)
SELECT 0                          AS revision,
       B.var_id                   AS var_id,
       A.var_code_subj            AS var_code,
       B.source_id                AS source_id,
       A.yr                       AS ver_no,
       A.univ_code,
       IFNULL(A.lev_subj, 1)      AS lev,
       IFNULL(A.val, 0)           AS val,
       JSON_OBJECT(
               'remark1', NULL,  -- todo
               'remark2', NULL,  -- todo
               'born_year', NULL,
               'dead_year', NULL,
               'effective', '1',
               'award_level', A.lev_name,
               'talent_name', A.talent_name,
               'current_code', NULL,
               'current_name', NULL,
               'elected_code', A.univ_code,
               'elected_name', A.univ_name,
               'elected_year', CONCAT(A.yr),
               'project_name', A.project_name,
               'subject_code', A.subject_code,
               'project_money', IFNULL(ROUND(A.val, 1), NULL),
               'val_display_suffix', IF(A.val_display_suffix = 1, '（估）', ''),
               'effective_last', NULL,
               'current_code_last', NULL,
               'current_name_last', NULL,
               'subject_code_last', NULL
           )                      AS detail,
       IFNULL(A.subject_code, '') AS subj_code,
       IFNULL(A.talent_code, '')  AS talent_code,
       A.talent_name,
       0                          AS agg_from,
       '100000'                   AS _eversions_,  -- todo
       100000                     AS _r_ver_no,  -- todo
       A.create_time              AS created_at,
       -1                         AS created_by,
       A.create_time              AS updated_at
FROM updated_data_template_1_20221205 A  -- todo
         JOIN spm_details_0208.var_rel_source B ON A.var_code_subj = B.var_code
WHERE A.is_add = 1;*/


# 学科平台：人才
/*INSERT INTO spm_details_0208.var_detail (revision, var_id, var_code, source_id, ver_no, univ_code, lev, val,
                                         detail, subj_code, talent_code, talent_name, agg_from, _eversions_,
                                         _r_ver_no, created_at, created_by, updated_at)
SELECT 0                           AS revision,
       B.var_id                    AS var_id,
       A.var_code_subj             AS var_code,
       B.source_id                 AS source_id,
       A.yr                        AS ver_no,
       A.univ_code,
       1                           AS lev,
       0                           AS val,
       JSON_OBJECT(
               'remark1', NULL,  -- todo
               'remark2', NULL,  -- todo
               'born_year', A.born_year,
               'dead_year', A.dead_year,
               'effective', '1',
               'award_level', NULL,
               'talent_name', A.talent_name,
               'current_code', A.current_code,
               'current_name', A.current_name,
               'elected_code', A.elected_code,
               'elected_name', A.elected_name,
               'elected_year', CONCAT(A.yr),
               'project_name', NULL,
               'subject_code', A.subject_code,
               'project_money', NULL,
               'effective_last', NULL,
               'current_code_last', NULL,
               'current_name_last', NULL,
               'subject_code_last', NULL
           )                       AS detail,
       IFNULL(A.subject_code, '')  AS subj_code,
       IFNULL(A.talent_code, '')   AS talent_code,
       IFNULL(A.talent_name, NULL) AS talent_name,
       0                           AS agg_from,
       '100000'                    AS _eversions_,  -- todo
       100000                      AS _r_ver_no,  -- todo
       A.create_time               AS created_at,
       -1                          AS created_by,
       A.create_time               AS updated_at
FROM updated_data_template_2_20221205 A  -- todo
         JOIN spm_details_0208.var_rel_source B ON A.var_code_subj = B.var_code
WHERE A.is_add = 1;*/














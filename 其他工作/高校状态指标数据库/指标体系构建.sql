# 根据兰涛给到的指标信息数据初步构建指标信息数据

# 指标查看

# 注：指标体系构建之前需要先执行变量明细数据迁移（变量数据已迁移则可忽略）
# 插入标签数据信息
USE hsid_ranking_dev;

SET FOREIGN_KEY_CHECKS = 0;
DELETE
FROM hsid_ranking_dev.indicator_tag
WHERE id > 0;
ALTER TABLE hsid_ranking_dev.indicator_tag
    AUTO_INCREMENT = 1;

SET @M_NO = 0;
INSERT INTO indicator_tag (pid, name, path, level, ord_no, is_intl)
WITH M AS (SELECT DISTINCT module FROM ub_details_raw.indicator_tag_raw ORDER BY ord_no)
SELECT 0, module, '', 1, (@M_NO := @M_NO + 1), 0
FROM M;

SET @T_NO = 0;
INSERT INTO indicator_tag (pid, name, path, level, ord_no, is_intl)
SELECT (SELECT id FROM indicator_tag B WHERE B.name = A.module), tag, '', 2, (@T_NO := @T_NO + 1), 0
FROM ub_details_raw.indicator_tag_raw A
ORDER BY ord_no;


# 插入指标信息（兰涛已确认的指标）
DELETE
FROM indicator
WHERE id > 0;
ALTER TABLE indicator
    AUTO_INCREMENT = 1;

INSERT INTO indicator (/*id, */pid, code, name, abbr, path, level, var_id, is_full_sample, detail_def_id, change_type,
                               definition, shows, tags, has_prov_det, is_single_ver, is_summable, charts, detail, val,
                               data_date, ord_no, remark, created_at, created_by, updated_at)
SELECT /*id,*/
    0                                   AS pid,
    code,
    name,
    abbr,
    ''                                  AS path,
    1                                   AS level,
    NULL                                AS var_id,
    IF(is_full_sample = '是', 1, 0)      AS is_full_sample,
    0                                   AS detail_def_id,
    0                                   AS change_type,
    definition,
    IF(`show` = '是', '1,2', '1')        AS shows, -- 相关页面是否显示
    (SELECT GROUP_CONCAT(C.id)
     FROM indicator_tag C
     WHERE level = 2
       AND FIND_IN_SET(C.name, REPLACE(A.tags, '、', ','))
       AND (SELECT FIND_IN_SET(name, REPLACE(A.module, '、', ',')) FROM indicator_tag WHERE id = C.pid)
    )                                   AS tags,
    IF(is_provincial = '是', 1, 0)       AS has_prov_det,
    IF(is_summable = '\\', 1, 0)        AS is_single_ver,
    IF(is_summable = '第一项', 0, 1)       AS is_summable,
    (CASE
         WHEN charts = '折线图' THEN 'line'
         WHEN charts = '折线图、柱状图' THEN CONCAT('line', ',', 'bar')
         ELSE '' END)                   AS charts,
    JSON_OBJECT(
            'availVer', availVer,
            'targetVer', targetVer,
            'aggSpan', aggSpan,
            'noActualVer', noActualVer,
            'sources', IF(sources IN ('', NULL), NULL, sources),
            'accessRule', accessRule,
            'filter', filter,
            'shows', shows,
            'raw', raw
        )                               AS detail,
    JSON_OBJECT(
            'decimals', decimals,
            'unitCode', unitCode,
            'isLowerBetter', isLowerBetter IS TRUE
        )                               AS val,
    DATE(NOW())                         AS data_date,
    ord_no,
    JSON_OBJECT(
            'source_product', source_product,
            'var_code', var_code,
            'ind_name', ind_name,
            'is_rank', is_rank,
            'source_rank', source_rank) AS remark,
    NOW()                               AS created_at,
    -1                                  AS created_by,
    NOW()                               AS updated_at
FROM ub_details_raw.hsid_ind_basics_table_20230130 A
WHERE var_code IS NOT NULL
ORDER BY ord_no;


# 插入变量信息（兰涛已确认的指标变量，现阶段一个指标只有一个变量）
INSERT INTO indicator (/*id, */pid, code, name, abbr, path, level, var_id, is_full_sample, detail_def_id, change_type,
                               definition, shows, tags, has_prov_det, is_single_ver, is_summable, charts, detail, val,
                               data_date, ord_no, remark, created_at, created_by, updated_at)
SELECT /*id,*/
    (SELECT DISTINCT B.id
     FROM indicator B
     WHERE A.var_code = B.remark ->> '$.var_code'
       AND A.code = B.code
       AND B.id != 0)                   AS pid,
    var_code,
    IFNULL(var_names, ''),
    IFNULL(var_names, ''),
    ''                                  AS path,
    2                                   AS level,
    NULL                                AS var_id,
    IF(is_full_sample = '是', 1, 0)      AS is_full_sample,
    0                                   AS detail_def_id,
    0                                   AS change_type,
    definition,
    IF(`show` = '是', '1,2', '1')        AS shows,
    ''                                  AS tags,
    IF(is_provincial = '是', 1, 0)       AS has_prov_det,
    IF(is_summable = '\\', 1, 0)        AS is_single_ver,
    IF(is_summable = '第一项', 0, 1)       AS is_summable,
    (CASE
         WHEN charts = '折线图' THEN 'line'
         WHEN charts = '折线图、柱状图' THEN CONCAT('line', ',', 'bar')
         ELSE '' END)                   AS charts,
    JSON_OBJECT(
            'availVer', availVer,
            'targetVer', targetVer,
            'aggSpan', aggSpan,
            'noActualVer', noActualVer,
            'sources', IF(sources IN ('', NULL), NULL, sources),
            'accessRule', accessRule,
            'filter', filter,
            'shows', shows,
            'raw', raw
        )                               AS detail,
    JSON_OBJECT(
            'decimals', decimals,
            'unitCode', unitCode,
            'isLowerBetter', isLowerBetter IS TRUE
        )                               AS val,
    DATE(NOW())                         AS data_date,
    ord_no,
    JSON_OBJECT(
            'source_product', source_product,
            'var_code', var_code,
            'ind_name', ind_name,
            'is_rank', is_rank,
            'source_rank', source_rank) AS remark,
    NOW()                               AS created_at,
    -1                                  AS created_by,
    NOW()                               AS updated_at
FROM ub_details_raw.hsid_ind_basics_table_20230130 A
WHERE var_code IS NOT NULL
ORDER BY ord_no;


# 特殊处理在国际交流模块下的指标标签
/*UPDATE indicator
SET tags = '39,40,59'
WHERE name = '国家自然科学基金国际(地区)合作与交流项目'
  AND level = 1;
UPDATE indicator
SET tags = '40,59'
WHERE name = '国家自然科学基金海外及港澳学者合作研究基金项目'
  AND level = 1;
UPDATE indicator
SET tags = '47,58'
WHERE name IN ('国家国际科技合作基地', '教育部国际合作联合实验室')
  AND level = 1;*/


SET FOREIGN_KEY_CHECKS = 1;


# 特殊处理只在省级模块下面显示的标签指标
UPDATE indicator
SET tags = IF(name = '省级一流本科课程', 66, 67)
WHERE name IN ('省级一流本科课程', '省级教学成果奖');


# 更新path
WITH
    RECURSIVE tree AS (
    SELECT id,
           CAST(NULL AS CHAR(50)) new_path /* 故意给 null，方便 后面进行 CONCAT_WS 时忽略根节点的 path；如果不这样处理，后续层级的节点，path 最前面会多一个逗号 */
    FROM hsid_ranking_dev.indicator i
    WHERE level = 1
    UNION ALL
    SELECT i.id, CONCAT_WS(',', tree.new_path, tree.id)
    FROM tree
             JOIN hsid_ranking_dev.indicator i ON i.pid = tree.id
)
UPDATE hsid_ranking_dev.indicator i JOIN tree t ON i.id = t.id
SET i.path = IFNULL(t.new_path, '')
WHERE i.id > 0;


# 处理 filter
UPDATE hsid_ranking_dev.indicator A JOIN ub_ranking_dev.v_ind_lat_l4_flat_wide B ON A.remark ->> '$.ind_name' = B.ind_name
SET A.detail = JSON_SET(A.detail, '$.filter', B.detail_filter)
WHERE A.detail ->> '$.filter' != 'null'
  AND A.level = 1;

UPDATE hsid_ranking_dev.indicator A JOIN hsid_ranking_dev.indicator B ON A.id = B.pid
SET B.detail = JSON_SET(B.detail, '$.filter', A.detail ->> '$.filter')
WHERE B.level = 2;

UPDATE hsid_ranking_dev.indicator
SET detail = JSON_SET(detail, '$.filter', CONCAT('ext.rating == "', REPLACE(detail ->> '$.filter', '学位中心排名：', ''), '"'))
WHERE detail ->> '$.filter' != 'null'
  AND detail ->> '$.filter' RLIKE '学位中心排名：';

UPDATE hsid_ranking_dev.indicator
SET detail = JSON_SET(detail, '$.filter', REPLACE(detail ->> '$.filter', 'performance', 'ext.rating'))
WHERE detail ->> '$.filter' != 'null'
  AND detail ->> '$.filter' RLIKE 'performance';

UPDATE hsid_ranking_dev.indicator
SET detail = JSON_SET(detail, '$.filter', (
    CASE
        WHEN detail ->> '$.filter' = '排名前N分之一：百分之一' THEN 'percentile <= 0.01'
        WHEN detail ->> '$.filter' = '排名前N分之一：千分之一' THEN 'percentile <= 0.001'
        WHEN detail ->> '$.filter' = '排名前N分之一：万分之一' THEN 'percentile <= 0.0001'
        WHEN detail ->> '$.filter' = '学科排名：≤50' THEN 'PickRankR(ranking) <= 50'
        WHEN detail ->> '$.filter' = '学科排名：≤50' THEN 'PickRankR(ranking) <= 50'
        WHEN detail ->> '$.filter' = '学科排名：≤50' THEN 'PickRankR(ranking) <= 50'
        WHEN detail ->> '$.filter' = '学科排名：≤5' THEN 'PickRankR(ranking) <= 5'
        WHEN detail ->> '$.filter' = '学科排名：≤25' THEN 'PickRankR(ranking) <= 25'
        WHEN detail ->> '$.filter' = '学科排名：≤100' THEN 'PickRankR(ranking) <= 100'
        WHEN detail ->> '$.filter' = '出生年：≥1942' THEN 'born_year >= 1942'
        WHEN detail ->> '$.filter' = '出生年：≥1942' THEN 'born_year >= 1942'
        WHEN detail ->> '$.filter' = 'PickRank(ranking) <= 50' THEN 'PickRankR(ranking) <= 50'
        WHEN detail ->> '$.filter' = 'PickPct(remark1) <= 5 || PickRank(ranks) <= 2'
            THEN 'PickRankR(ranking) <= 2  || percentile <= 0.05'
        WHEN detail ->> '$.filter' = 'PickPct(remark1) <= 40 || PickRank(ranks) <= 2'
            THEN 'PickRankR(ranking) <= 2  || percentile <= 0.4'
        WHEN detail ->> '$.filter' = 'PickPct(remark1) <= 30 || PickRank(ranks) <= 2'
            THEN 'PickRankR(ranking) <= 2  || percentile <= 0.3'
        WHEN detail ->> '$.filter' = 'PickPct(remark1) <= 20 || PickRank(ranks) <= 2'
            THEN 'PickRankR(ranking) <= 2  || percentile <= 0.2'
        WHEN detail ->> '$.filter' = 'PickPct(remark1) <= 2 || PickRank(ranks) <= 2'
            THEN 'PickRankR(ranking) <= 2  || percentile <= 0.02'
        WHEN detail ->> '$.filter' = 'PickPct(remark1) <= 10 || PickRank(ranks) <= 2'
            THEN 'PickRankR(ranking) <= 2  || percentile <= 0.1'
        WHEN detail ->> '$.filter' = '硕士点' THEN 'master == "1"'
        WHEN detail ->> '$.filter' = '博士点' THEN 'doctor == "1"'
        WHEN detail ->> '$.filter' = '一级博士点' THEN 'full_doctor == "1"'
        WHEN detail ->> '$.filter' = '重点项目' THEN 'remark1 == "重点项目"'
        WHEN detail ->> '$.filter' = '一般项目' THEN 'remark1 == "一般项目"'
        WHEN detail ->> '$.filter' = '青年项目' THEN 'remark1 == "青年项目"'
        END
    ))
WHERE detail ->> '$.filter' != 'null'
  AND detail ->> '$.filter' IN (
                                '排名前N分之一：百分之一',
                                '排名前N分之一：千分之一',
                                '排名前N分之一：万分之一',
                                '学科排名：≤50',
                                '学科排名：≤50',
                                '学科排名：≤50',
                                '学科排名：≤5',
                                '学科排名：≤25',
                                '学科排名：≤100',
                                '出生年：≥1942',
                                '出生年：≥1942',
                                'PickRank(ranking) <= 50',
                                'PickPct(remark1) <= 5 || PickRank(ranks) <= 2',
                                'PickPct(remark1) <= 40 || PickRank(ranks) <= 2',
                                'PickPct(remark1) <= 30 || PickRank(ranks) <= 2',
                                'PickPct(remark1) <= 20 || PickRank(ranks) <= 2',
                                'PickPct(remark1) <= 2 || PickRank(ranks) <= 2',
                                'PickPct(remark1) <= 10 || PickRank(ranks) <= 2',
                                '硕士点',
                                '博士点',
                                '一级博士点',
                                '重点项目',
                                '一般项目',
                                '青年项目');

# 全国大学生数学建模竞赛缺数据，暂无法确定filter
SELECT code, name, detail ->> '$.filter', detail
FROM hsid_ranking_dev.indicator
WHERE detail ->> '$.filter' != 'null'
  AND level = 2
ORDER BY ord_no;



# 处理明细表头
# 添加负责列
ALTER TABLE hsid_ranking_dev.ind_detail_def
    ADD COLUMN _ub_id  int(0) NULL AFTER id,
    ADD COLUMN _spm_id int(0) NULL AFTER _ub_id;

ALTER TABLE hsid_ranking_dev.ind_detail_field
    ADD COLUMN _ub_def_id  int(0) NULL AFTER def_id,
    ADD COLUMN _spm_def_id int(0) NULL AFTER _ub_def_id;

# 360
UPDATE hsid_ranking_dev.indicator a JOIN ub_ranking_dev.indicator_latest b ON a.remark ->> '$.ind_name' = b.name AND b.level = 3
SET a.detail_def_id = b.detail_def_id
WHERE a.remark ->> '$.source_product' = '360'
  AND a.id != 0
--  AND a.level = 1
;

/*UPDATE hsid_ranking_dev.indicator a JOIN ub_ranking_dev.indicator_latest b ON a.remark ->> '$.var_code' = b.code AND b.level = 4
SET a.detail_def_id = b.detail_def_id
WHERE a.remark ->> '$.source_product' = '360'
  AND a.id != 0
  AND a.level = 2;*/

# 学科
UPDATE hsid_ranking_dev.indicator a JOIN spm_ranking_dev.indicator_latest b ON a.remark ->> '$.ind_name' = b.name AND b.level = 3
SET a.detail_def_id = b.detail_def_id
WHERE a.remark ->> '$.source_product' = '学科'
  AND a.id != 0
--  AND a.level = 1
;

/*UPDATE hsid_ranking_dev.indicator a JOIN spm_ranking_dev.indicator_latest b ON a.remark ->> '$.var_code' = b.code AND b.level = 4
SET a.detail_def_id = b.detail_def_id
WHERE a.remark ->> '$.source_product' = '学科'
  AND a.id != 0
  AND a.level = 2;*/


SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE hsid_ranking_dev.ind_detail_def;
TRUNCATE TABLE hsid_ranking_dev.ind_detail_field;

ALTER TABLE hsid_ranking_dev.ind_detail_field
    DROP INDEX def_id,
    ADD INDEX def_id (def_id, field_key) USING BTREE;

# 360
INSERT INTO hsid_ranking_dev.ind_detail_def (_ub_id, _spm_id, name, table_width, tip, remark, created_at,
                                             updated_at, deleted_at)
SELECT id   AS _ub_id,
       NULL AS _spm_id,
       name,
       table_width,
       tip,
       remark,
       created_at,
       updated_at,
       deleted_at
FROM ub_ranking_dev.ind_detail_def;

INSERT INTO hsid_ranking_dev.ind_detail_field (def_id, _ub_def_id, _spm_def_id, field_key, field_name,
                                               transformation, attribute, char_limit, show_width, tip, align, special,
                                               ord_no, remark, created_at, updated_at, deleted_at)
SELECT 0      AS def_id,
       def_id AS _ub_def_id,
       NULL   AS _spm_def_id,
       field_key,
       field_name,
       transformation,
       attribute,
       char_limit,
       show_width,
       tip,
       align,
       special,
       ord_no,
       remark,
       created_at,
       updated_at,
       deleted_at
FROM ub_ranking_dev.ind_detail_field;

# 学科
INSERT INTO hsid_ranking_dev.ind_detail_def (_ub_id, _spm_id, name, table_width, tip, remark, created_at,
                                             updated_at, deleted_at)
SELECT NULL AS _ub_id,
       id   AS _spm_id,
       name,
       table_width,
       ''      tip,
       remark,
       created_at,
       updated_at,
       deleted_at
FROM spm_ranking_dev.ind_detail_def;

INSERT INTO hsid_ranking_dev.ind_detail_field (def_id, _ub_def_id, _spm_def_id, field_key, field_name,
                                               transformation, attribute, char_limit, show_width, tip, align, special,
                                               ord_no, remark, created_at, updated_at, deleted_at)
SELECT 0      AS def_id,
       NULL   AS _ub_def_id,
       def_id AS _spm_def_id,
       field_key,
       field_name,
       transformation,
       ''        attribute,
       char_limit,
       show_width,
       tip,
       align,
       special,
       ord_no,
       remark,
       created_at,
       updated_at,
       deleted_at
FROM spm_ranking_dev.ind_detail_field;


SET FOREIGN_KEY_CHECKS = 1;


UPDATE hsid_ranking_dev.ind_detail_field a JOIN hsid_ranking_dev.ind_detail_def b ON a._ub_def_id = B._ub_id
SET a.def_id = b.id
WHERE a._ub_def_id IS NOT NULL;

UPDATE hsid_ranking_dev.ind_detail_field a JOIN hsid_ranking_dev.ind_detail_def b ON a._spm_def_id = B._spm_id
SET a.def_id = b.id
WHERE a._spm_def_id IS NOT NULL;


# 更新指标表： detail_def_id
UPDATE hsid_ranking_dev.indicator a JOIN hsid_ranking_dev.ind_detail_def b ON a.detail_def_id = b._ub_id
SET a.detail_def_id = b.id
WHERE a.id != 0
  AND a.remark ->> '$.source_product' = '360';

UPDATE hsid_ranking_dev.indicator a JOIN hsid_ranking_dev.ind_detail_def b ON a.detail_def_id = b._spm_id
SET a.detail_def_id = b.id
WHERE a.id != 0
  AND a.remark ->> '$.source_product' = '学科';


# 清理不需要的表头信息
UPDATE hsid_ranking_dev.ind_detail_field
SET deleted_at = NOW()
WHERE field_name IN ('折合数', '权重', '现职单位', '系数', '头衔', '课程类型', '认定类型', '重点学科类别', '现职单位', '汇总列');

UPDATE hsid_ranking_dev.ind_detail_field
SET deleted_at = NOW()
WHERE field_name = '类型'
  AND transformation != '';

ALTER TABLE hsid_ranking_dev.ind_detail_field
    DROP INDEX def_id,
    ADD UNIQUE INDEX def_id (def_id, field_key) USING BTREE;

DELETE
FROM hsid_ranking_dev.ind_detail_field
WHERE def_id NOT IN (SELECT detail_def_id FROM indicator);

DELETE
FROM hsid_ranking_dev.ind_detail_def
WHERE id NOT IN (SELECT detail_def_id FROM indicator);


# 根据兰涛的要求更新部分指标表头
UPDATE hsid_ranking_dev.ind_detail_field
SET field_key  = 'elected_year',
    field_name = '入选年份',
    special    = '',
    show_width = 100,
    deleted_at = NULL
WHERE field_key = 'project_money'
  AND field_name = '系数';

UPDATE hsid_ranking_dev.ind_detail_field
SET field_key      = 'elected_year',
    field_name     = '认证年份',
    transformation = '',
    special        = '',
    show_width     = 100,
    deleted_at     = NULL
WHERE field_key = 'var_name'
  AND field_name = '认定类型';


# 更新省级科技奖励和省级教学成果奖表头
UPDATE hsid_ranking_dev.ind_detail_field A JOIN hsid_ranking_dev.indicator B ON A.def_id = B.detail_def_id
SET A.field_key      = 'award_level',
    A.transformation = ''
WHERE B.name IN ('省级教学成果奖', '省级科技奖励')
  AND A.field_name = '等级';


# 排名变量标准代码更新
UPDATE hsid_ranking_dev.indicator a
    JOIN _ur.ur_ranking_type b ON a.name = b.name
SET a.code = b.code
WHERE a.level = 2
  AND a.detail ->> '$.raw' = 'RANKING';


# 学校属性变量特殊处理
UPDATE indicator
SET var_id = -10000
WHERE pid IN (1, 2, 3, 4, 5);


# 删除来自学科平台表头的学科字段（除排名指标）
UPDATE ind_detail_field
SET deleted_at = NOW()
WHERE field_key = 'subject_name'
  AND _spm_def_id IS NOT NULL
  AND def_id IN (
    SELECT detail_def_id
    FROM indicator
    WHERE id != 0
      AND remark ->> '$.source_product' = '学科'
      AND detail ->> '$.raw' != 'RANKING');


# 删除辅助列
ALTER TABLE hsid_ranking_dev.ind_detail_def
    DROP COLUMN _ub_id,
    DROP COLUMN _spm_id;

ALTER TABLE hsid_ranking_dev.ind_detail_field
    DROP COLUMN _ub_def_id,
    DROP COLUMN _spm_def_id;


# 学校属性那几个指标的数据来源（detail.sources）
# 1. 建校年份，用 7	各学校网站
# 2. 其他属性，用 16	教育部网站
UPDATE hsid_ranking_dev.indicator
SET detail = JSON_SET(detail, '$.sources', '7')
WHERE id = 1
   OR pid = 1;

UPDATE hsid_ranking_dev.indicator
SET detail = JSON_SET(detail, '$.sources', '16')
WHERE id IN (2, 3, 4, 5)
   OR pid IN (2, 3, 4, 5);

WITH var_s AS (SELECT var_code, GROUP_CONCAT(DISTINCT src_id) sources FROM hsid_details.var_detail GROUP BY var_code)
UPDATE hsid_ranking_dev.indicator A JOIN var_s B ON A.remark ->> '$.var_code' = B.var_code
SET A.detail = JSON_SET(A.detail, '$.sources', B.sources)
WHERE (A.detail ->> '$.sources' = 'null' OR A.detail ->> '$.sources' IS NULL)
  AND A.id != 0;


# 排名类指标来源
UPDATE hsid_ranking_dev.indicator A JOIN hsid_details.var_detail_source B ON A.remark ->> '$.sources_rank' = B.name
SET A.detail = JSON_SET(detail, '$.sources', B.id)
WHERE A.detail ->> '$.raw' = 'RANKING';


# 更新指标新表中var_id
UPDATE hsid_ranking_dev.indicator A JOIN hsid_details.variable B ON A.remark ->> '$.var_code' = B.code
SET A.var_id = IF(A.tags = '16', -10000, B.id)
WHERE A.level = 2;

UPDATE hsid_ranking_dev.indicator
SET var_id = -10000
WHERE level = 2
  AND tags = '16';

UPDATE hsid_ranking_dev.indicator
SET var_id = -10001
WHERE level = 2
  AND detail ->> '$.raw' = 'RANKING';


# 更新一下remark中ind_name对应的ind_code
UPDATE hsid_ranking_dev.indicator a JOIN ub_ranking_dev.indicator_latest b ON a.remark ->> '$.ind_name' = b.name
SET a.remark = JSON_SET(a.remark, '$.ind_code', b.code)
WHERE a.remark ->> '$.source_product' = '360'
  AND b.level = 3
  AND a.id != 0;

UPDATE hsid_ranking_dev.indicator a JOIN spm_ranking_dev.indicator_latest b ON a.remark ->> '$.ind_name' = b.name
SET a.remark = JSON_SET(a.remark, '$.ind_code', b.code)
WHERE a.remark ->> '$.source_product' = '学科'
  AND b.level = 3
  AND a.id != 0;


# 处理ESI指标及变量信息
UPDATE hsid_ranking_dev.indicator
SET detail = JSON_SET(detail, '$.verListBy', 'ESI')
WHERE name RLIKE 'ESI';

# 清空JSON中空值
/*UPDATE hsid_ranking_dev.indicator
SET detail = help.reduce0(detail),
    val    = help.reduce0(val)
WHERE 1;*/


# 已有表头的指标
/*SELECT A.code 指标代码,
       A.name 指标名称,
       A.remark ->> '$.var_code'       AS 变量代码,
       A.remark ->> '$.source_product' AS 平台来源,
       B.*
FROM hsid_ranking_dev.indicator A
         JOIN ind_detail_field B ON A.detail_def_id = def_id
WHERE detail ->> '$.shows' IS NOT NULL
  AND level = 1
  AND B.deleted_at IS NULL
  AND A.remark ->> '$.source_product' != 'null'
ORDER BY A.ord_no, B.def_id, B.ord_no;*/


# 与兰涛给的表头对比
/*WITH base AS ( -- 联合两张表查询对比需要的字段
    SELECT id
         , code
         , name
         , detail_def_id
         , (SELECT GROUP_CONCAT(f.field_name ORDER BY f.ord_no)
            FROM ind_detail_field f
            WHERE f.def_id = i.detail_def_id
              AND f.deleted_at IS NULL) fields_in_table
         -- 将空格分隔的字符串，改为逗号分隔的字符串
         , (SELECT REGEXP_REPLACE(TRIM(TRIM(LEADING '序号' FROM TRIM(def))), '\\s+', ',')
            FROM ub_details_raw.hsid_ind_basics_table_20230130 f
            WHERE f.code = i.code)      fields_in_excel
    FROM indicator i
    WHERE deleted_at IS NULL
      AND level = 1)
SELECT id
     , code
     , name
     , detail_def_id
     , fields_in_table
     , fields_in_excel
     -- 数据库相比 excel，多出的表头字段
     , (SELECT GROUP_CONCAT(jt.field_name)
        FROM JSON_TABLE(CAST(CONCAT('["', REPLACE(fields_in_table, ',', '","'), '"]') AS JSON), '$[*]'
                        COLUMNS (field_name VARCHAR(20) PATH '$')) jt
        WHERE NOT FIND_IN_SET(field_name, IFNULL(fields_in_excel, ''))) extra
     -- 数据库相比 excel，缺少的表头字段
     , (SELECT GROUP_CONCAT(jt.field_name)
        FROM JSON_TABLE(CAST(CONCAT('["', REPLACE(fields_in_excel, ',', '","'), '"]') AS JSON), '$[*]'
                        COLUMNS (field_name VARCHAR(20) PATH '$')) jt
        WHERE NOT FIND_IN_SET(field_name, IFNULL(fields_in_table, ''))) short
FROM base
GROUP BY detail_def_id, fields_in_table, fields_in_excel,
         extra,
         short
HAVING (extra IS NOT NULL
    OR short IS NOT NULL)
   AND detail_def_id != 0;*/


# 根据兰涛要求临时删除部分指标（五年统计总数）
UPDATE hsid_ranking_dev.indicator
SET deleted_at = NOW()
WHERE remark ->> '$.var_code' IN ('72', '74', '75')
  AND id != 0;

# 复合指标：本科毕业生未就业率、学生总数
UPDATE hsid_ranking_dev.indicator
SET deleted_at = NOW()
WHERE code IN ('hsid_209', 'hsid_157');


# 周佳新增用于学位点变量搜索用的表头信息
INSERT INTO hsid_ranking_dev.ind_detail_def(id, name, remark, created_at, updated_at)
VALUES (77, '学位点', 'subt', NOW(), NOW());

INSERT INTO hsid_ranking_dev.ind_detail_field(def_id, field_key, field_name, transformation, char_limit, show_width,
                                              align, ord_no,
                                              created_at, updated_at)
VALUES (77, 'school_name', '学校名称', '', -1, 0, 'center', 1, NOW(), NOW()),
       (77, 'subj_lev', '学科层次', 'subj_lev', -1, 0, 'center', 2, NOW(), NOW()),
       (77, 'subject_code', '学科代码', '', -1, 0, 'center', 3, NOW(), NOW()),
       (77, 'subject_name', '学科名称', '', -1, 0, 'center', 4, NOW(), NOW()),
       (77, 'data_year', '数据年份', '', -1, 0, 'center', 5, NOW(), NOW());

UPDATE indicator
SET detail_def_id = 77
WHERE level = 2
  AND code = 'subt';


# 根据指标表关联表头表，更新指定指标的表头信息
# 省级教学成果奖、省级科技奖励的等级
UPDATE hsid_ranking_dev.ind_detail_field A JOIN hsid_ranking_dev.indicator B ON A.def_id = B.detail_def_id
SET A.field_key      = 'award_level',
    A.transformation = ''
WHERE B.code IN ('hsid_424', 'hsid_425')
  AND A.field_name = '等级';

# 国家最高科学技术奖
UPDATE hsid_ranking_dev.ind_detail_field A JOIN hsid_ranking_dev.indicator B ON A.def_id = B.detail_def_id
SET A.deleted_at = NOW()
WHERE B.code = 'hsid_306'
  AND A.field_name IN ('等级', '获奖项目名称');

# 省级科技奖励
UPDATE hsid_ranking_dev.ind_detail_field A JOIN hsid_ranking_dev.indicator B ON A.def_id = B.detail_def_id
SET A.deleted_at = NULL
WHERE B.code = 'hsid_425'
  AND A.field_name = '类型';


# 更新BCUR过滤子榜条件
# 指标
UPDATE hsid_ranking_dev.indicator
SET detail = JSON_SET(detail, '$.filter', CONCAT('r_code_sub == "', code, '"'))
WHERE level = 1
  AND code LIKE 'BCUR%';

# 变量
WITH i AS (SELECT id, detail ->> '$.filter' filter
           FROM hsid_ranking_dev.indicator
           WHERE level = 1
             AND code LIKE 'BCUR%')
UPDATE hsid_ranking_dev.indicator v JOIN i ON v.pid = i.id
SET detail = JSON_SET(detail, '$.filter', i.filter)
WHERE v.level = 2
  AND v.code = 'BCUR';


# 增加排名类指标表头信息
UPDATE ub_details_raw.hsid_ind_basics_table_20230130
SET def = -- REGEXP_REPLACE(TRIM(TRIM(LEADING '序号' FROM TRIM(def))), '\\s+', ',')
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(TRIM(def), '  ', ' '), '  ', ' '), '  ', ' '), '  ', ' '), '  ',
                        ' '), ' ', ',')
WHERE detail_shows = '是';


# ind_detail_def
INSERT INTO hsid_ranking_dev.ind_detail_def (name, table_width, tip, remark, created_at)
SELECT name, 0, '', code, NOW()
FROM ub_details_raw.hsid_ind_basics_table_20230130
WHERE is_rank IS NOT NULL
  AND detail_shows = '是';

UPDATE hsid_ranking_dev.indicator A JOIN hsid_ranking_dev.ind_detail_def B ON A.code = B.remark
SET A.detail_def_id = B.id
WHERE A.detail ->> '$.raw' = 'RANKING';

WITH i AS (SELECT id, detail_def_id
           FROM hsid_ranking_dev.indicator
           WHERE level = 1
             AND detail ->> '$.raw' = 'RANKING')
UPDATE hsid_ranking_dev.indicator v JOIN i ON v.pid = i.id
SET v.detail_def_id = i.detail_def_id
WHERE v.level = 2
  AND v.detail ->> '$.raw' = 'RANKING';


# ind_detail_field
INSERT INTO hsid_ranking_dev.ind_detail_field (def_id, field_key, field_name, char_limit, show_width, ord_no)
WITH detail_field AS (
    SELECT A.*, B.source_product, CONCAT('["', REPLACE(B.def, ',', '","'), '"]') AS def
    FROM hsid_ranking_dev.indicator A
             JOIN ub_details_raw.hsid_ind_basics_table_20230130 B ON B.code = A.code
    WHERE B.is_rank IS NOT NULL
      AND B.detail_shows = '是'
      AND A.level = 1),
     build_def_json_row AS (
         SELECT m.id  AS ind_id,
                detail_def_id,
                source_product,
                t2.id AS ord_no,
                t2.name_zh
         FROM detail_field m,
              JSON_TABLE(
                      CAST(def AS JSON),
                      '$[*]' COLUMNS (
                          id FOR ORDINALITY ,
                          name_zh VARCHAR(20) PATH '$'
                          )
                  ) AS t2
     )
SELECT detail_def_id def_id, name_zh field_key, name_zh field_name, -1 char_limit, 0 show_width, (ord_no - 1) ord_no
FROM build_def_json_row
WHERE name_zh != '序号';


# 更新field_key
UPDATE hsid_ranking_dev.ind_detail_field
SET field_key = (CASE field_key
                     WHEN '学校名称' THEN 'univ_name'
                     WHEN '学科代码' THEN 'r_code_sub'
                     WHEN '学科名称' THEN 'RI_name'
                     WHEN '学位中心排名' THEN 'ranking'
                     WHEN '参评高校数' THEN 'RI_num_rank'
                     WHEN '年份' THEN 'RI_version'
                     WHEN '软科排名' THEN 'ranking'
                     WHEN '软科百分段位' THEN 'percentile'
                     WHEN '数据年份' THEN 'RI_version'
                     WHEN '学科排名' THEN 'ranking'
                     WHEN '版本' THEN 'RI_version'
                     WHEN '发布时间' THEN 'RV_release_date'
                     WHEN 'ESI学科名称' THEN 'RI_name'
                     WHEN 'ESI学科排名' THEN 'ranking'
                     WHEN '入选ESI机构总数' THEN 'RI_num_pub'
                     WHEN '第一轮学科评估' THEN 'ranking'
                     WHEN '入选年份' THEN 'RI_version'
                     WHEN '第二轮学科评估' THEN 'ranking'
                     WHEN '第三轮学科评估' THEN 'ranking'
                     ELSE field_name
    END)
WHERE field_key = field_name;


# 部分表头特殊处理
UPDATE hsid_ranking_dev.ind_detail_field
SET transformation = 'percent_top'
WHERE field_name = '软科百分段位'
  AND field_key = 'percentile';


# 检查filter
-- SELECT * FROM hsid_ranking_dev.indicator WHERE detail ->> '$.filter' = 'null';

/*UPDATE hsid_ranking_dev.indicator
SET detail = REPLACE(detail,'"filter": "null",','')
WHERE detail ->> '$.filter' = 'null';*/


# 处理表头宽度
UPDATE hsid_ranking_dev.ind_detail_field A JOIN hsid_ranking_dev.indicator B ON A.def_id = detail_def_id AND
                                                                                B.detail ->> '$.raw' = 'RANKING' AND
                                                                                B.level = 1
SET A.show_width = 100
WHERE A.field_name IN ('年份', '入选年份', '发布时间', '数据年份');



# 国际对比
# 模块标签
INSERT INTO hsid_ranking_dev.indicator_tag (id, pid, name, path, level, ord_no, is_intl)
VALUES (69, 0, '国际对比', '', 1, 1, 1),
       (70, 69, '国际排名', '', 2, 1, 1),
       (71, 69, '学科水平', '', 2, 2, 1),
       (72, 69, '科学研究', '', 2, 3, 1),
       (73, 69, '国际化', '', 2, 4, 1),
       (74, 69, '教学', '', 2, 4, 1),
       (75, 69, '资源', '', 2, 4, 1);

# 新增指标
INSERT INTO indicator (/*id, */pid, code, name, abbr, path, level, var_id, is_full_sample, detail_def_id, change_type,
                               definition, shows, tags, has_prov_det, is_single_ver, is_summable, charts, detail, val,
                               data_date, ord_no, remark, created_at, created_by, updated_at)
SELECT /*id,*/
    0                                   AS pid,
    code,
    name,
    abbr,
    ''                                  AS path,
    1                                   AS level,
    NULL                                AS var_id,
    IF(is_full_sample = '是', 1, 0)      AS is_full_sample,
    0                                   AS detail_def_id,
    0                                   AS change_type,
    definition,
    3                                   AS shows,       -- 相关页面是否显示
    (SELECT GROUP_CONCAT(C.id)
     FROM indicator_tag C
     WHERE level = 2
       AND FIND_IN_SET(C.name, REPLACE(A.tags, '、', ','))
       AND (SELECT FIND_IN_SET(name, REPLACE(A.page, '、', ',')) FROM indicator_tag WHERE id = C.pid)
    )                                   AS tags,
    IF(is_provincial = '是', 1, 0)       AS has_prov_det,
    IF(is_summable = '\\', 1, 0)        AS is_single_ver,
    0                                   AS is_summable, -- 已和兰涛沟通，国际对比新增的指标均不可汇总
    (CASE
         WHEN charts = '折线图' THEN 'line'
         WHEN charts = '折线图、柱状图' THEN CONCAT('line', ',', 'bar')
         ELSE '' END)                   AS charts,
    JSON_OBJECT(
            'availVer', availVer,
            'targetVer', targetVer,
            'aggSpan', aggSpan,
            'noActualVer', noActualVer,
            'sources', IF(sources IN ('', NULL), NULL, sources),
            'accessRule', accessRule,
            'filter', filter,
            'shows', IF(shows = '是', 'val_gt0', NULL),
            'raw', IF(is_rank = '是', 'RANKING', NULL)
        )                               AS detail,
    JSON_OBJECT(
            'decimals', decimals,
            'unitCode', unitCode,
            'isLowerBetter', isLowerBetter IS TRUE
        )                               AS val,
    DATE(NOW())                         AS data_date,
    ord_no,
    JSON_OBJECT(
            'source_product', source_product,
            'var_code', var_code,
            'ind_name', ind_name,
            'is_rank', is_rank,
            'source_rank', source_rank) AS remark,
    NOW()                               AS created_at,
    -2                                  AS created_by,
    NOW()                               AS updated_at
FROM ub_details_raw.hsid_intl_ind_basics_table_20230130 A
WHERE A.is_add = '是'
ORDER BY ord_no;


# 新增变量
INSERT INTO indicator (/*id, */pid, code, name, abbr, path, level, var_id, is_full_sample, detail_def_id, change_type,
                               definition, shows, tags, has_prov_det, is_single_ver, is_summable, charts, detail, val,
                               data_date, ord_no, remark, created_at, created_by, updated_at)
SELECT /*id,*/
    (SELECT DISTINCT B.id
     FROM indicator B
     WHERE A.var_code = B.remark ->> '$.var_code'
       AND A.code = B.code
       AND B.id != 0)                   AS pid,
    var_code,
    IFNULL(var_names, ''),
    IFNULL(var_names, ''),
    ''                                  AS path,
    2                                   AS level,
    IF(is_rank = '是', -10001, NULL)     AS var_id,
    IF(is_full_sample = '是', 1, 0)      AS is_full_sample,
    0                                   AS detail_def_id,
    0                                   AS change_type,
    definition,
    3                                   AS shows,
    ''                                  AS tags,
    IF(is_provincial = '是', 1, 0)       AS has_prov_det,
    IF(is_summable = '\\', 1, 0)        AS is_single_ver,
    0                                   AS is_summable, -- 已和兰涛沟通，国际对比新增的指标均不可汇总
    (CASE
         WHEN charts = '折线图' THEN 'line'
         WHEN charts = '折线图、柱状图' THEN CONCAT('line', ',', 'bar')
         ELSE '' END)                   AS charts,
    JSON_OBJECT(
            'availVer', availVer,
            'targetVer', targetVer,
            'aggSpan', aggSpan,
            'noActualVer', noActualVer,
            'sources', IF(sources IN ('', NULL), NULL, sources),
            'accessRule', accessRule,
            'filter', filter,
            'shows', IF(shows = '是', 'val_gt0', NULL),
            'raw', IF(is_rank = '是', 'RANKING', NULL)
        )                               AS detail,
    JSON_OBJECT(
            'decimals', decimals,
            'unitCode', unitCode,
            'isLowerBetter', isLowerBetter IS TRUE
        )                               AS val,
    DATE(NOW())                         AS data_date,
    ord_no,
    JSON_OBJECT(
            'source_product', source_product,
            'var_code', var_code,
            'ind_name', ind_name,
            'is_rank', is_rank,
            'source_rank', source_rank) AS remark,
    NOW()                               AS created_at,
    -2                                  AS created_by,
    NOW()                               AS updated_at
FROM ub_details_raw.hsid_intl_ind_basics_table_20230130 A
WHERE A.is_add = '是'
ORDER BY ord_no;

UPDATE hsid_ranking_dev.indicator
SET deleted_at = NOW()
WHERE detail ->> '$.aggSpan' = '5'
  AND name RLIKE 'Q1期刊论文比例'  -- Q1期刊论文已有数据，取消删除标记,Q1期刊论文比例无数据仍需标记删除
  AND created_by = -2
  AND id != 0;


# 更新国际对比使用到指标查看指标的shows、tags
UPDATE hsid_ranking_dev.indicator A
    JOIN ub_details_raw.hsid_intl_ind_basics_table_20230130 B ON A.code = B.code
SET A.shows = CONCAT_WS(',', A.shows, 3),
    A.tags  = CONCAT_WS(',', A.tags,
                        (SELECT GROUP_CONCAT(C.id)
                         FROM hsid_ranking_dev.indicator_tag C
                         WHERE level = 2
                           AND FIND_IN_SET(C.name, REPLACE(B.tags, '、', ','))
                           AND (SELECT FIND_IN_SET(name, REPLACE(B.page, '、', ','))
                                FROM hsid_ranking_dev.indicator_tag
                                WHERE id = C.pid)
                        )
        )
WHERE B.is_add = '否'
  AND A.level = 1;


# 新增指标表头处理
INSERT INTO hsid_ranking_dev.ind_detail_def (name, remark)
SELECT C.name, C.code
FROM ub_ranking_dev.ind_detail_def A
         JOIN ub_ranking_derived.derived_indicator B ON A.id = B.detail_def_id
         JOIN hsid_ranking_dev.indicator C ON C.remark ->> '$.var_code' = B.code
WHERE B.r_type_id = 5
  AND C.shows RLIKE '3'
  AND C.level = 1;



# 区分国际国内
UPDATE hsid_ranking_dev.ind_detail_def
SET name = '科睿唯安高被引科学家（国内）'
WHERE remark = 'thomson';

INSERT INTO hsid_ranking_dev.ind_detail_field (def_id, field_key, field_name, char_limit, show_width, ord_no,
                                               deleted_at)
SELECT D.id, field_key, field_name, char_limit, show_width, A.ord_no, A.deleted_at
FROM ub_ranking_dev.ind_detail_field A
         JOIN ub_ranking_derived.derived_indicator B ON A.def_id = B.detail_def_id
         JOIN hsid_ranking_dev.indicator C ON C.remark ->> '$.var_code' = B.code
         JOIN hsid_ranking_dev.ind_detail_def D ON D.name = C.name
WHERE B.r_type_id = 5
  AND C.shows RLIKE '3'
  AND C.level = 1
ORDER BY id, ord_no;

UPDATE hsid_ranking_dev.indicator A JOIN hsid_ranking_dev.ind_detail_def B ON A.name = B.name
SET A.detail_def_id = B.id
WHERE A.name IN (
                 '获诺贝尔奖校友数',
                 '获菲尔兹奖校友数',
                 '获诺贝尔科学奖教师数',
                 '获菲尔兹奖教师数',
                 '获其他国际权威奖项教师数','科睿唯安高被引科学家'
    ) AND A.detail_def_id = 0;


UPDATE hsid_ranking_dev.indicator
SET detail_def_id = (SELECT id FROM hsid_ranking_dev.ind_detail_def WHERE name = 'ESI前1‱学科数')
WHERE name RLIKE 'ESI'
  AND name NOT RLIKE 'ESI综合被引次数排名'
  AND detail_def_id = 0;


# 处理Nature Index学科排名表头
UPDATE hsid_ranking_dev.indicator
SET detail_def_id = (SELECT id FROM hsid_ranking_dev.ind_detail_def WHERE name = 'RUR世界大学学科排名上榜学科数')
WHERE name IN (
               'Nature Index学科排名前50名学科数',
               'Nature Index学科排名上榜学科数',
               'Nature Index学科排名'
    );


# 更新指标新表中var_id
UPDATE hsid_ranking_dev.indicator A JOIN hsid_details.variable B ON A.remark ->> '$.var_code' = B.code
SET A.var_id = IF(A.tags = '16', -10000, B.id)
WHERE A.level = 2;


# 更新detail.sources
WITH S AS (
    SELECT var_code, GROUP_CONCAT(DISTINCT src_id) sources FROM hsid_details.var_detail GROUP BY var_code)
UPDATE hsid_ranking_dev.indicator A JOIN S ON A.remark ->> '$.var_code' = S.var_code
SET A.detail = JSON_SET(detail, '$.sources', S.sources)
WHERE A.created_by = -2;


# 对排名类指标是否为全样本数据进行特殊处理-关关
WITH r AS (SELECT id,
                  code,
                  name,
                  is_full_sample,
                  (SELECT rank_target
                   FROM _ur.ur_ranking_type t
                   WHERE t.code = (SELECT code FROM indicator WHERE pid = i.id)) rank_target
           FROM indicator i
           WHERE LEVEL = 1
             AND detail ->> '$.raw' = 'RANKING')
# SELECT * FROM r;
UPDATE r JOIN hsid_ranking_dev.indicator i USING (id)
SET i.is_full_sample = 0
WHERE rank_target = 'univ';



# 检查filter
-- SELECT * FROM hsid_ranking_dev.indicator WHERE detail ->> '$.filter' = 'null';

UPDATE hsid_ranking_dev.indicator
SET detail = REPLACE(detail, '"filter": "null",', '')
WHERE detail ->> '$.filter' = 'null';


# 处理JSON中的空值
UPDATE hsid_ranking_dev.indicator
SET detail = help.reduce0(detail),
    val    = help.reduce0(val)
WHERE 1;


# 更新排名类指标来源：关关
WITH s AS ( -- 排名类指标，匹配来源
    SELECT id
         , code
         , name
         , detail
         , CASE
               WHEN code RLIKE '^CUSR' THEN '教育部学位与研究生教育发展中心'
               WHEN code RLIKE '^(BCSR|BCUR|ARWU|GRAS|RUGC)' THEN '软科官网'
               WHEN code RLIKE '^ESI' THEN 'ESI官网'
               WHEN code RLIKE '^THE' THEN 'THE官网'
               WHEN code RLIKE '^QS' THEN 'QS官网'
               WHEN code RLIKE '^USNEWS' THEN 'U.S.News官网'
               WHEN code RLIKE '^CWUR' THEN 'CWUR官网'
               WHEN code RLIKE '^CWTS' THEN 'CWTS官网'
               WHEN code RLIKE '^RUR' THEN 'RUR排名官网'
               WHEN code RLIKE '^MOSIUR' THEN '莫斯科国际大学排名官网'
               WHEN code RLIKE '^SCIMAGO' THEN 'Scimago世界大学排名官网'
               WHEN code RLIKE '^NTU' THEN 'NTU世界大学排名官网'
               WHEN code RLIKE '^URAP' THEN 'URAP世界大学学术质量排名官网'
               WHEN code RLIKE '^CSIC' THEN 'CSIC世界大学排名官网'
               WHEN code RLIKE '^NI' THEN '自然指数（Nature Index）排名官网'
               WHEN code RLIKE '^WSL' THEN '雅学网' -- 武书连官网
               WHEN code RLIKE '^QJP' THEN '金平果中国科教评价网' -- 邱均平官网
               WHEN code RLIKE '^XYH' THEN '艾瑞深校友会网' -- 校友会官网
               WHEN code RLIKE '^GZDSR' THEN '广州日报数据和数字化研究院'
               ELSE help.err(CONCAT_WS(' ', '未匹配数据来源', code, name))
        END                                                                              new_src_name
         , (SELECT id FROM hsid_details.var_detail_source s WHERE s.name = new_src_name) new_src_id
    FROM indicator
    WHERE detail ->> '$.raw' = 'RANKING')
# SELECT id, code, name, detail, new_src_name, new_src_id FROM s;
UPDATE hsid_ranking_dev.indicator i JOIN s USING (id)
SET i.detail = JSON_SET(i.detail, '$.sources', CONCAT(s.new_src_id))
WHERE TRUE;



# 临时删除CWUR世界大学排名：关关
UPDATE hsid_ranking_dev.indicator
SET deleted_at = NOW()
WHERE name = 'CWUR世界大学排名';













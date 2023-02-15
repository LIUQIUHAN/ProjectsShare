USE hsid_details;
SET @_r_ver_no = 202302;
SET @_eversions_ = '202302';
SET FOREIGN_KEY_CHECKS = 0;

# 变量信息表
# 新增辅助列
ALTER TABLE hsid_details.variable
    ADD COLUMN _ub_id  int(0) NULL AFTER id,
    ADD COLUMN _spm_id int(0) NULL AFTER _ub_id;

ALTER TABLE hsid_details.var_detail_def
    ADD COLUMN _ub_id  int(0) NULL AFTER id,
    ADD COLUMN _spm_id int(0) NULL AFTER _ub_id;

ALTER TABLE hsid_details.var_detail_field
    ADD COLUMN _ub_def_id  int(0) NULL AFTER def_id,
    ADD COLUMN _spm_def_id int(0) NULL AFTER _ub_def_id;

/*ALTER TABLE hsid_details.var_detail_source
    ADD COLUMN _ub_id  int(0) NULL AFTER id,
    ADD COLUMN _spm_id int(0) NULL AFTER _ub_id;*/

/*ALTER TABLE hsid_details.var_detail_source
    DROP INDEX name,
    ADD INDEX name (_spm_id, _ub_id) USING BTREE;*/


TRUNCATE TABLE hsid_details.variable;

INSERT INTO hsid_details.variable (/*id, */ _ub_id, _spm_id, code, name, val_unit_code, val_decimals, detail_def_id,
                                            outdated, remark, created_at, created_by, updated_at, updated_by)
SELECT /*id,*/
    id   AS _ub_id,
    NULL AS _spm_id,
    code,
    name,
    val_unit_code,
    val_decimals,
    detail_def_id,
    outdated,
    remark,
    created_at,
    created_by,
    updated_at,
    updated_by
FROM ub_details_0429.variable A
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.code = B.var_code
               AND B.source_product = '360');

INSERT INTO hsid_details.variable (/*id, */_ub_id, _spm_id, code, name, val_unit_code, val_decimals, detail_def_id,
                                           outdated, remark, created_at, created_by, updated_at, updated_by)
SELECT /*id,*/
    NULL AS _ub_id,
    id   AS _spm_id,
    code,
    name,
    val_unit_code,
    val_decimals,
    detail_def_id,
    outdated,
    remark,
    created_at,
    created_by,
    updated_at,
    updated_by
FROM spm_details_0208.variable A
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.code = B.var_code
               AND B.source_product = '学科');



TRUNCATE TABLE hsid_details.var_detail_def;
TRUNCATE TABLE hsid_details.var_detail_field;

ALTER TABLE hsid_details.var_detail_def
    DROP INDEX name,
    ADD INDEX name (name) USING BTREE;

ALTER TABLE hsid_details.var_detail_field
    DROP INDEX def_id,
    ADD INDEX def_id (def_id, field_key) USING BTREE;


INSERT INTO hsid_details.var_detail_def (_ub_id, _spm_id, name, created_at, created_by, updated_at, updated_by,
                                         deleted_at, deleted_by)
SELECT id   _ub_id,
       NULL _spm_id,
       name,
       created_at,
       created_by,
       updated_at,
       updated_by,
       deleted_at,
       deleted_by
FROM ub_details_0429.var_detail_def
WHERE 1;

INSERT INTO hsid_details.var_detail_def (_ub_id, _spm_id, name, created_at, created_by, updated_at, updated_by,
                                         deleted_at, deleted_by)
SELECT NULL _ub_id,
       id   _spm_id,
       name,
       created_at,
       created_by,
       updated_at,
       updated_by,
       deleted_at,
       deleted_by
FROM spm_details_0208.var_detail_def
WHERE 1;


INSERT INTO hsid_details.var_detail_field (def_id, _ub_def_id, _spm_def_id, field_key, field_name, uni_check,
                                           is_required, ord_no, remark, created_at, updated_at, deleted_at)
SELECT def_id,
       def_id _ub_def_id,
       NULL   _spm_def_id,
       field_key,
       field_name,
       uni_check,
       is_required,
       ord_no,
       remark,
       created_at,
       updated_at,
       deleted_at
FROM ub_details_0429.var_detail_field
WHERE 1;

INSERT INTO hsid_details.var_detail_field (def_id, _ub_def_id, _spm_def_id, field_key, field_name, uni_check,
                                           is_required, ord_no, remark, created_at, updated_at, deleted_at)
SELECT def_id,
       NULL   _ub_def_id,
       def_id _spm_def_id,
       field_key,
       field_name,
       uni_check,
       is_required,
       ord_no,
       remark,
       created_at,
       updated_at,
       deleted_at
FROM spm_details_0208.var_detail_field
WHERE 1;


UPDATE hsid_details.var_detail_field A JOIN hsid_details.var_detail_def B ON A._ub_def_id = B._ub_id
SET A.def_id = B.id
WHERE A._ub_def_id IS NOT NULL;

UPDATE hsid_details.var_detail_field A JOIN hsid_details.var_detail_def B ON A._spm_def_id = B._spm_id
SET A.def_id = B.id
WHERE A._spm_def_id IS NOT NULL;

UPDATE hsid_details.variable A JOIN var_detail_def B ON A.detail_def_id = B._ub_id
SET A.detail_def_id = B.id
WHERE A._ub_id IS NOT NULL;

UPDATE hsid_details.variable A JOIN var_detail_def B ON A.detail_def_id = B._spm_id
SET A.detail_def_id = B.id
WHERE A._spm_id IS NOT NULL;

DELETE
FROM hsid_details.var_detail_def A
WHERE NOT EXISTS(SELECT * FROM hsid_details.variable B WHERE A.id = B.detail_def_id);

DELETE
FROM hsid_details.var_detail_field A
WHERE NOT EXISTS(SELECT * FROM hsid_details.variable B WHERE A.def_id = B.detail_def_id);

ALTER TABLE hsid_details.var_detail_def
    DROP INDEX name,
    ADD UNIQUE INDEX name (name) USING BTREE;

ALTER TABLE hsid_details.var_detail_field
    DROP INDEX def_id,
    ADD UNIQUE INDEX def_id (def_id, field_key) USING BTREE;


# 变量来源
TRUNCATE TABLE hsid_details.var_detail_source;

INSERT INTO hsid_details.var_detail_source (name, remark, created_at, created_by, updated_at,
                                            updated_by, deleted_at, deleted_by)
SELECT name,
       remark,
       created_at,
       created_by,
       updated_at,
       updated_by,
       deleted_at,
       deleted_by
FROM ub_details_0429.var_detail_source;

INSERT INTO hsid_details.var_detail_source (name, remark, created_at, created_by, updated_at,
                                            updated_by, deleted_at, deleted_by)
SELECT name,
       '' AS remark,
       created_at,
       created_by,
       updated_at,
       updated_by,
       deleted_at,
       deleted_by
FROM spm_details_0208.var_detail_source A
WHERE NOT EXISTS(SELECT * FROM hsid_details.var_detail_source B WHERE A.name = B.name);


# 变量明细数据
TRUNCATE TABLE hsid_details.var_detail;

INSERT INTO hsid_details.var_detail (revision, var_id, var_code, src_id, ver_no, univ_code, lev, val,
                                     detail, rel_code, agg_from, created_at, created_by, updated_at)
SELECT A.revision,
       C.id,
       A.var_code,
       B.id AS src_id,
       A.ver_no,
       A.univ_code,
       A.lev,
       A.val,
       A.detail,
       A.rel_code,
       A.agg_from,
       A.created_at,
       A.created_by,
       A.updated_at
FROM ub_details_0429.var_detail A
         JOIN hsid_details.variable C ON A.var_code = C.code
         JOIN ub_details_0429.var_detail_source D ON A.source_id = D.id
         JOIN hsid_details.var_detail_source B ON B.name = D.name
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '360'
               AND A._r_ver_no IN (@_r_ver_no, 0))
  AND A.deleted_at IS NULL
ORDER BY A.var_code, A.ver_no;



INSERT INTO hsid_details.var_detail (revision, var_id, var_code, src_id, ver_no, univ_code, lev, val,
                                     detail, rel_code, agg_from, created_at, created_by, updated_at)
SELECT revision,
       89           id,
       'psaward' AS var_code,
       6         AS src_id,
       ver_no,
       univ_code,
       lev,
       val,
       detail,
       rel_code,
       agg_from,
       created_at,
       created_by,
       updated_at
FROM ub_details_0429.var_detail
WHERE _r_ver_no = @_r_ver_no
  AND deleted_at IS NULL
  AND var_code IN ('posaward', 'psaward2', 'psaward4', 'psaward6', 'psaward8', 'psaward9', 'pysaward')
ORDER BY ver_no;


INSERT INTO hsid_details.var_detail (revision, var_id, var_code, src_id, ver_no, univ_code, lev, val,
                                     detail, rel_code, agg_from, created_at, created_by, updated_at)
SELECT A.revision,
       C.id,
       A.var_code,
       B.id AS src_id,
       A.ver_no,
       A.univ_code,
       A.lev,
       A.val,
       A.detail,
       A.talent_code,
       A.agg_from,
       A.created_at,
       A.created_by,
       A.updated_at
FROM spm_details_0208.var_detail A
         JOIN hsid_details.variable C ON A.var_code = C.code
         JOIN spm_details_0208.var_detail_source D ON A.source_id = D.id
         JOIN hsid_details.var_detail_source B ON B.name = D.name
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '学科'
               AND A._eversions_ = @_eversions_)
  AND A.deleted_at IS NULL
ORDER BY A.var_code, A.ver_no;


# 清理冗余数据
DELETE
FROM hsid_details.variable A
WHERE NOT EXISTS(SELECT * FROM hsid_details.var_detail B WHERE A.code = B.var_code);

SET FOREIGN_KEY_CHECKS = 1;


# 处理变量明细的等级
TRUNCATE TABLE hsid_details.var_detail_lev;

INSERT INTO hsid_details.var_detail_lev (var_id, var_code, var_name, lev, lev_name, prov_code, prov_name, remark)
SELECT B.id,
       B.code,
       B.name,
       A.lev,
       A.award_name lev_name,
       0            prov_code,
       ''           prov_name,
       B.remark
FROM ub_details_0429.var_detail_lev A
         JOIN hsid_details.variable B ON A.var_code = B.code
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '360');

INSERT INTO hsid_details.var_detail_lev (var_id, var_code, var_name, lev, lev_name, prov_code, prov_name, remark)
SELECT B.id,
       B.code,
       B.name,
       A.lev,
       A.award_name lev_name,
       0            prov_code,
       ''           prov_name,
       B.remark
FROM spm_details_0208.var_detail_lev A
         JOIN hsid_details.variable B ON A.var_code = B.code
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '学科');


# 更新指标新表中var_id
UPDATE hsid_ranking_dev.indicator A JOIN hsid_details.variable B ON A.remark ->> '$.var_code' = B.code
SET A.var_id = IF(A.tags = '16', -10000, B.id)
WHERE A.level = 2;

UPDATE hsid_ranking_dev.indicator
SET var_id = -10000
WHERE level = 2
  AND tags = '16';


# 删除辅助列
ALTER TABLE hsid_details.variable
    DROP COLUMN _ub_id,
    DROP COLUMN _spm_id;

ALTER TABLE hsid_details.var_detail_def
    DROP COLUMN _ub_id,
    DROP COLUMN _spm_id;

ALTER TABLE hsid_details.var_detail_field
    DROP COLUMN _ub_def_id,
    DROP COLUMN _spm_def_id;

/*ALTER TABLE hsid_details.var_detail_source
    DROP INDEX name,
    ADD INDEX name (name),
    DROP COLUMN _ub_id,
    DROP COLUMN _spm_id;*/


# 处理国家一流本科专业数据（从学科平台拿过来的数据有重复，因为学科平台一条明细划分在了多个学科，以多条记录存储）
UPDATE hsid_details.var_detail
SET deleted_at = NOW(),
    revision   = 1
WHERE var_code = 'k2';

INSERT INTO hsid_details.var_detail(det_id, revision, var_id, var_code, src_id, ver_no, univ_code, lev, val, detail,
                                    agg_from, created_at, created_by, updated_at, updated_by, deleted_at, deleted_by)
SELECT det_id,
       0    AS revision,
       var_id,
       var_code,
       src_id,
       ver_no,
       univ_code,
       lev,
       val,
       detail,
       agg_from,
       created_at,
       created_by,
       updated_at,
       updated_by,
       NULL AS deleted_at,
       NULL AS deleted_by
FROM hsid_details.var_detail
WHERE var_code = 'k2'
GROUP BY univ_code, ver_no, detail ->> '$.project_name';

DELETE
FROM hsid_details.var_detail
WHERE var_code = 'k2'
  AND deleted_at IS NOT NULL;


# var_lev_conv 信息迁移
TRUNCATE TABLE hsid_ranking_dev.var_lev_conv;

INSERT INTO hsid_ranking_dev.var_lev_conv (var_code, var_name, prov_code, prov_name, lev, lev_name, var_name_full,
                                           remark, created_at, updated_at)
SELECT A.var_code,
       B.name,
       A.province_code prov_code,
       IFNULL(C.name_short, ''),
       A.lev,
       A.lev_name,
       A.var_name_full,
       A.remark,
       A.created_at,
       A.updated_at
FROM ub_ranking_dev.var_lev_conv A
         JOIN hsid_details.variable B ON A.var_code = B.code
         LEFT JOIN univ_ranking_dev.gi_province C ON C.code = A.province_code
WHERE A.r_ver_no = @_r_ver_no
  AND EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '360'
               AND A.r_ver_no = @_r_ver_no);


INSERT INTO hsid_ranking_dev.var_lev_conv (var_code, var_name, prov_code, prov_name, lev, lev_name, var_name_full,
                                           remark, created_at, updated_at)
SELECT A.var_code,
       B.name,
       A.province_code prov_code,
       IFNULL(C.name_short, ''),
       A.lev,
       A.lev_name,
       ''              var_name_full,
       A.remark,
       A.created_at,
       A.updated_at
FROM spm_ranking_dev.var_lev_conv A
         JOIN hsid_details.variable B ON A.var_code = B.code
         LEFT JOIN univ_ranking_dev.gi_province C ON C.code = A.province_code
WHERE A.r_ver_no = @_r_ver_no
  AND A.r_root_id = 1
  AND EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '学科'
               AND A.r_ver_no = @_r_ver_no);



# 人才类变量数据使用其当选单位
# 有48条数据elected_code为null，但是其当选单位为专职高校，可将univ_code赋值给elected_code
UPDATE hsid_details.var_detail
SET detail = JSON_SET(detail, '$.elected_code', univ_code)
WHERE detail ->> '$.elected_code' = 'null'
  AND var_code IN (
                   'h1', 'h2', 'r12', 'h3', 'h4', 'r10', 'r13', 'r14', 'h6',
                   'h5', 'h8', 'h7', 'thomson', 'elsevier', 'e3', 'e1', 'xp1',
                   'r4', 'r1', 'r2', 'r17', 'r5', 'r7', 'o12','kxyhxr_1','gcyhxr_2'
    );


# 有一条数据elected_code为'',根据elected_name（广东以色列理工学院）更新elected_code
UPDATE hsid_details.var_detail
SET detail = JSON_SET(detail, '$.elected_code', 'RC00958')
WHERE detail ->> '$.elected_code' = ''
  AND var_code IN (
                   'h1', 'h2', 'r12', 'h3', 'h4', 'r10', 'r13', 'r14', 'h6',
                   'h5', 'h8', 'h7', 'thomson', 'elsevier', 'e3', 'e1', 'xp1',
                   'r4', 'r1', 'r2', 'r17', 'r5', 'r7', 'o12','kxyhxr_1','gcyhxr_2'
    );


# 提取当选elected_code作为univ_code
UPDATE hsid_details.var_detail
SET univ_code = detail ->> '$.elected_code'
WHERE var_code IN (
                   'h1', 'h2', 'r12', 'h3', 'h4', 'r10', 'r13', 'r14', 'h6',
                   'h5', 'h8', 'h7', 'thomson', 'elsevier', 'e3', 'e1', 'xp1',
                   'r4', 'r1', 'r2', 'r17', 'r5', 'r7', 'o12','kxyhxr_1','gcyhxr_2'
    );


# 有107条数据elected_code（univ_code）非统一的R开头的代码
UPDATE hsid_details.var_detail A
SET A.univ_code = IFNULL(
        (SELECT B.code FROM univ_ranking_dev.univ_cn B WHERE A.univ_code = B._code_old AND B.outdated = 0 LIMIT 1),
        A.univ_code)
WHERE A.univ_code NOT RLIKE 'R'
  AND A.univ_code != 'XXXXX'
  AND A.var_code IN (
                     'h1', 'h2', 'r12', 'h3', 'h4', 'r10', 'r13', 'r14', 'h6',
                     'h5', 'h8', 'h7', 'thomson', 'elsevier', 'e3', 'e1', 'xp1',
                     'r4', 'r1', 'r2', 'r17', 'r5', 'r7', 'o12','kxyhxr_1','gcyhxr_2'
    );


UPDATE hsid_details.var_detail A
SET A.univ_code = IFNULL((SELECT B.code
                          FROM univ_ranking_dev.univ_cn_academy B
                          WHERE A.detail ->> '$.elected_name' = B.name_cn
                            AND B.outdated = 0
                          LIMIT 1), A.univ_code)
WHERE A.univ_code NOT RLIKE 'R'
  AND A.univ_code != 'XXXXX'
  AND A.var_code IN (
                     'h1', 'h2', 'r12', 'h3', 'h4', 'r10', 'r13', 'r14', 'h6',
                     'h5', 'h8', 'h7', 'thomson', 'elsevier', 'e3', 'e1', 'xp1',
                     'r4', 'r1', 'r2', 'r17', 'r5', 'r7', 'o12','kxyhxr_1','gcyhxr_2'
    );


# 检查（除J开头还有2条数据匹配不到R代码-南京工业职业技术大学：RC01558）
# 处理：南京工业职业技术大学-RC01558
UPDATE hsid_details.var_detail
SET univ_code = 'RC01558'
WHERE univ_code = 'G0276';

# 除了人才类的变量，其他很多变量的univ_code均非标准的R代码
UPDATE hsid_details.var_detail A
SET A.univ_code = IFNULL(
        (SELECT B.code FROM univ_ranking_dev.univ_cn B WHERE A.univ_code = B._code_old AND B.outdated = 0 LIMIT 1),
        A.univ_code)
WHERE A.univ_code NOT RLIKE 'R'
  AND A.univ_code != 'XXXXX';


UPDATE hsid_details.var_detail A
SET A.univ_code = IFNULL((SELECT B.code
                          FROM univ_ranking_dev.univ_cn_academy B
                          WHERE A.detail ->> '$.elected_name' = B.name_cn
                            AND B.outdated = 0
                          LIMIT 1), A.univ_code)
WHERE A.univ_code NOT RLIKE 'R'
  AND A.univ_code != 'XXXXX';


UPDATE hsid_details.var_detail
SET univ_code = 'XXXXX'
WHERE univ_code = '\\'
  AND univ_code != 'XXXXX';



# 迁移国际对标的部分变量数据
# 77_0	Nature和Science论文
# 72	国际核心期刊论文总数
# 74	国际核心期刊高被引论文数
# 75	国际核心期刊论文总被引次数

# 变量信息
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO hsid_details.variable (code, name, val_unit_code, val_decimals, detail_def_id,
                                   outdated, remark, created_at, created_by, updated_at, updated_by)
SELECT code,
       name,
       val_unit_code,
       val_decimals,
       0    detail_def_id,
       outdated,
       code remark,
       created_at,
       created_by,
       updated_at,
       updated_by
FROM ub_details_0429.intl_variable A
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.code = B.var_code
               AND B.source_product = '360_intl');

# 来源信息
/*INSERT INTO hsid_details.var_detail_source (name, remark, created_by)
SELECT name, var_code remark, -1 created_by
FROM ub_details_0429.intl_var_source
WHERE var_code IN ('72', '74', '75', '77_0')
      AND name != 'WOS';*/


# 变量数据
INSERT INTO hsid_details.var_detail (revision, var_id, var_code, src_id, ver_no, univ_code, lev, val,
                                     detail, agg_from,
                                     created_at, created_by, updated_at)
SELECT A.revision,
       C.id,
       A.var_code,
       B.id,
       A.ver_no,
       A.univ_code,
       A.lev,
       A.val,
       NULL detail,
       A.agg_from,
       A.created_at,
       A.created_by,
       A.updated_at
FROM ub_details_0429.intl_var_detail A
         JOIN hsid_details.variable C ON A.var_code = C.remark
         JOIN ub_details_0429.intl_var_source D ON A.var_code = D.var_code AND A.source_id = D.src_id
         JOIN hsid_details.var_detail_source B ON B.name = D.name
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '360_intl')
ORDER BY A.var_code, A.ver_no;


# 清理辅助数据
UPDATE variable
SET remark = ''
WHERE remark IN ('72', '74', '75', '77_0');
UPDATE var_detail_source
SET remark = ''
WHERE remark IN ('72', '74', '75', '77_0');


# 增加排名类指标变量信息（最后确认：排名类无需增加变量信息）
/*INSERT INTO hsid_details.variable (code, name, val_unit_code, val_decimals, detail_def_id, outdated, remark, created_by)
SELECT DISTINCT code,
                name,
                ''   val_unit_code,
                0    val_decimals,
                0    detail_def_id,
                0    outdated,
                code remark,
                -1   created_by
FROM hsid_ranking_dev.indicator
WHERE detail ->> '$.raw' = 'RANKING'
  AND level = 2;*/


# 增加排名类指标变量来源信息
INSERT INTO hsid_details.var_detail_source (name, remark, created_by)
SELECT DISTINCT source_rank name, '' remark, -1 created_by
FROM ub_details_raw.hsid_ind_basics_table_20230130
WHERE is_rank = '是';


SET FOREIGN_KEY_CHECKS = 1;









USE hsid_details;


# 变量信息
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO hsid_details.variable (code, name, val_unit_code, val_decimals, detail_def_id, outdated, remark, created_at,
                                   created_by, updated_at, updated_by)
SELECT code,
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
FROM ub_details_0429.intl_variable A
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_intl_ind_basics_table_20230130 B
             WHERE A.code = B.var_code
               AND B.source_product = '360');

UPDATE hsid_details.variable
SET name = IF(code = '69','科睿唯安高被引科学家（国际）','科睿唯安高被引科学家（国内）')
WHERE code IN ('69','thomson');


# 来源
INSERT INTO hsid_details.var_detail_source (name, created_by)
SELECT DISTINCT name, -1
FROM ub_details_0429.intl_var_source A
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_intl_ind_basics_table_20230130 B
             WHERE A.var_code = B.var_code
               AND B.source_product = '360')
  AND NOT EXISTS(SELECT * FROM hsid_details.var_detail_source C WHERE A.name = C.name);


# 变量数据
INSERT INTO hsid_details.var_detail (revision, var_id, var_code, src_id, ver_no, univ_code, lev, val, detail, rel_code,
                                     agg_from, created_at, created_by, updated_at)
SELECT revision,
       D.id var_id,
       A.var_code,
       C.id src_id,
       ver_no,
       univ_code,
       lev,
       val,
       detail,
       rel_code,
       agg_from,
       A.created_at,
       A.created_by,
       A.updated_at
FROM ub_details_0429.intl_var_detail A
         JOIN ub_details_0429.intl_var_source B ON A.var_code = B.var_code AND A.source_id = B.src_id
         JOIN hsid_details.var_detail_source C ON B.name = C.name
         JOIN hsid_details.variable D ON A.var_code = D.code
WHERE EXISTS(SELECT *
             FROM ub_details_raw.hsid_intl_ind_basics_table_20230130 E
             WHERE A.var_code = E.var_code
               AND E.source_product = '360');


SET FOREIGN_KEY_CHECKS = 1;


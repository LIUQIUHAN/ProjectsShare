USE ub_details_raw;

SET @scheme_id = 6;
SET @_eversions_ = '202302';

DELETE
FROM spm_ranking_dev.cut_scheme_detail
WHERE scheme_id = @scheme_id;

ALTER TABLE spm_ranking_dev.cut_scheme_detail
    AUTO_INCREMENT 0;

INSERT INTO spm_ranking_dev.cut_scheme_detail (scheme_id, dtl_id, revision, talent_code, subj_code, percent, created_at,
                                               created_by)
SELECT @scheme_id AS scheme_id,
       A.dtl_id,
       A.revision,
       A.talent_code,
       A.subj_code,
       1          AS percent,
       NOW()      AS created_at,
       -1         AS created_by
FROM spm_details_0208.var_detail A
         JOIN ub_details_raw.cut_detail_data B
              ON A.var_code = B.var_code AND A.ver_no = B.ver_no AND A.talent_code = B.talent_code AND B.is_use = '可用'
WHERE A._eversions_ = @_eversions_
  AND A.univ_code != 'XXXXX'
  AND A.subj_code != ''
  AND A.subj_code != '1401'
  AND A.subj_code != '1402'
  AND A.deleted_at IS NULL
GROUP BY A.dtl_id;


INSERT INTO spm_ranking_dev.cut_scheme_detail (scheme_id, dtl_id, revision, talent_code, subj_code, percent, created_at,
                                               created_by)
SELECT @scheme_id AS scheme_id,
       A.dtl_id,
       A.revision,
       A.talent_code,
       B.cut_subj_code,
       1          AS percent,
       NOW()      AS created_at,
       -1         AS created_by
FROM spm_details_0208.var_detail A
         JOIN ub_details_raw.cut_detail_data B
              ON A.var_code = B.var_code AND A.ver_no = B.ver_no AND A.talent_code = B.talent_code AND B.is_use = '可用'
WHERE A._eversions_ = @_eversions_
  AND A.univ_code != 'XXXXX'
  AND A.subj_code != ''
  AND A.subj_code != '1401'
  AND A.subj_code != '1402'
  AND A.deleted_at IS NULL
GROUP BY A.dtl_id;



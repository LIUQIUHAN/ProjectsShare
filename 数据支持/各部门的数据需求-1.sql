USE ub_details_0429;

# 20221223
# 指标
SELECT A.univ_code 学校代码, B.name_cn 学校名称, C.name 指标名称, A.target_ver 年份, A.val 指标值, A.alt_val 替代值
FROM ub_ranking_dev.ind_value_latest A
         LEFT JOIN univ_ranking_dev.univ_cn B ON A.univ_code = B.code AND B.outdated = 0
         JOIN ub_ranking_dev.indicator_latest C ON A.ind_code = C.code AND C.level = 3
WHERE ind_code IN (SELECT code
                   FROM ub_ranking_dev.indicator_latest
                   WHERE `level` = 3
                     AND `name` IN (
                                    '学校收入（总额）',
                                    '社会捐赠收入（总额）',
                                    '教师学历结构（博士学位教师占比）',
                                    '教师职称结构（高级职称教师占比）',
                                    '教授授课率',
                                    '授课教授比例',
                                    '本科毕业生深造率',
                                    '国家重大奖励（折合数）',
                                    '教育部科学技术奖（折合数）',
                                    '高被引科学家'
                       ))
  AND A.target_ver NOT RLIKE '-'

ORDER BY A.ind_code, A.target_ver, A.univ_code;


# 变量
# 检查变量中ver_no是否有=0：没有
SELECT *
FROM ub_details_0429.var_detail
WHERE var_code IN (
                   'add1049',
                   'r85',
                   'add1046',
                   'oto2',
                   'r83',
                   'add1048',
                   'oto3',
                   'r84',
                   'oto5',
                   'j22',
                   'oto6',
                   'oto7',
                   'jygz001',
                   'add1047',
                   'oto1',
                   'add1055',
                   'j21',
                   'r81',
                   'add1053',
                   'add1051',
                   'r22',
                   'r82',
                   'oto8',
                   'add1050',
                   'j23',
                   'oto9',
                   'oto10',
                   'oto11',
                   'add1054',
                   'oto4',
                   'add1060',
                   'sz2',
                   'sz5',
                   'sizeng16',
                   'sz340',
                   'fwsh001',
                   'fwsh002',
                   'fwsh003',
                   'fwsh004',
                   'fwsh005',
                   'fwsh006',
                   'h1',
                   'h2',
                   'p2',
                   'p3',
                   'p6',
                   'p7',
                   'b66',
                   'b68'
    )
  AND ver_no = 0
  AND _r_ver_no = 202301;

# 360
SELECT a.var_code                                             变量代码,
       b.name                                                 变量名称,
       a.univ_code                                            学校代码,
       c.name_cn                                              学校名称,
       a.ver_no                                               年份,
       COUNT(*)                                               项数,
       IF(a.var_code IN ('p2', 'p3'), ROUND(SUM(val), 1), '') 金额
FROM ub_details_0429.var_detail a
         JOIN ub_details_0429.variable b ON a.var_code = b.code
         LEFT JOIN univ_ranking_dev.univ_cn c ON a.univ_code = c.code AND c.outdated = 0
WHERE a._r_ver_no = 202301
  AND a.univ_code != 'XXXXX'
  AND a.var_code IN (
                     'add1049',
                     'r85',
                     'add1046',
                     'oto2',
                     'r83',
                     'add1048',
                     'oto3',
                     'r84',
                     'oto5',
                     'j22',
                     'oto6',
                     'oto7',
                     'jygz001',
                     'add1047',
                     'oto1',
                     'add1055',
                     'j21',
                     'r81',
                     'add1053',
                     'add1051',
                     'r22',
                     'r82',
                     'oto8',
                     'add1050',
                     'j23',
                     'oto9',
                     'oto10',
                     'oto11',
                     'add1054',
                     'oto4',
                     'add1060',
                     'sz2',
                     'sz5',
                     'sizeng16',
                     'sz340',
                     'fwsh001',
                     'fwsh002',
                     'fwsh003',
                     'fwsh004',
                     'fwsh005',
                     'fwsh006',
                     'h1',
                     'h2',
                     'p2',
                     'p3',
                     'p6',
                     'p7',
                     'b66',
                     'b68'
    )
GROUP BY var_code, univ_code, ver_no
ORDER BY var_code, ver_no, univ_code;


SELECT a.var_code                                             变量代码,
       b.name                                                 变量名称,
       a.detail ->> '$.elected_code'                          当选单位代码,
       a.detail ->> '$.elected_name'                          当选单位名称,
       a.ver_no,
       COUNT(*)                                               项数,
       IF(a.var_code IN ('p2', 'p3'), ROUND(SUM(val), 1), '') 金额
FROM ub_details_0429.var_detail a
         JOIN ub_details_0429.variable b ON a.var_code = b.code
         LEFT JOIN univ_ranking_dev.univ_cn c ON a.univ_code = c.code AND c.outdated = 0
WHERE a._r_ver_no = 202301
  AND a.var_code IN (
                     'h1',
                     'h2'
    )
GROUP BY var_code, a.detail ->> '$.elected_name', ver_no
ORDER BY var_code, ver_no, univ_code;


# 学科
SELECT a.var_code                                             变量代码,
       b.name                                                 变量名称,
       a.univ_code                                            学校代码,
       c.name_cn                                              学校名称,
       a.ver_no                                               年份,
       COUNT(*)                                               项数,
       IF(a.var_code IN ('p2', 'p3'), ROUND(SUM(val), 1), '') 金额
FROM spm_details_0208.var_detail a
         JOIN spm_details_0208.variable b ON a.var_code = b.code
         LEFT JOIN univ_ranking_dev.univ_cn c ON a.univ_code = c.code AND c.outdated = 0
WHERE a._eversions_ = '202301'
  AND a.univ_code != 'XXXXX'
  AND a.var_code IN (
                     'west1',
                     'x27'
    )
GROUP BY var_code, univ_code, ver_no
ORDER BY var_code, ver_no, univ_code;


# 挑战杯和互联网+
SELECT a.var_code                                             变量代码,
       b.name                                                 变量名称,
       a.univ_code                                            学校代码,
       c.name_cn                                              学校名称,
       a.ver_no                                               年份,
       a.detail ->> '$.award_level'                           等级名称,
       COUNT(*)                                               项数,
       IF(a.var_code IN ('p2', 'p3'), ROUND(SUM(val), 1), '') 金额
FROM ub_details_0429.var_detail a
         JOIN ub_details_0429.variable b ON a.var_code = b.code
         LEFT JOIN univ_ranking_dev.univ_cn c ON a.univ_code = c.code AND c.outdated = 0
WHERE a._r_ver_no = 202301
  AND a.univ_code != 'XXXXX'
  AND a.var_code IN (
                     'b68', 'b66'
    )
GROUP BY var_code, univ_code, ver_no, lev
ORDER BY var_code, ver_no, univ_code;


# 国家大学科技园和国家技术转移示范机构的评价结果
SELECT a.var_code                                             变量代码,
       b.name                                                 变量名称,
       a.univ_code                                            学校代码,
       c.name_cn                                              学校名称,
       a.ver_no                                               年份,
       a.detail ->> '$.award_level'                           评价结果,
       COUNT(*)                                               项数,
       IF(a.var_code IN ('p2', 'p3'), ROUND(SUM(val), 1), '') 金额
FROM ub_details_0429.var_detail a
         JOIN ub_details_0429.variable b ON a.var_code = b.code
         LEFT JOIN univ_ranking_dev.univ_cn c ON a.univ_code = c.code AND c.outdated = 0
WHERE a._r_ver_no = 202301
  AND a.univ_code != 'XXXXX'
  AND a.var_code IN (
                     'fwsh001', 'fwsh002'
    )
GROUP BY var_code, univ_code, ver_no, a.detail ->> '$.award_level'
ORDER BY var_code, ver_no, univ_code;


# 应研究部需求，需要拉取360和学科平台内无机构编码的所有指标明细数据，即机构编码为XXXX的明细数据
SELECT 360                            平台,
       A.dtl_id,
       A.var_code,
       B.name,
       A.ver_no,
       A.lev,
       A.val,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.rel_code                     人才代码或专业代码
FROM ub_details_0429.var_detail A
         LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
WHERE A._r_ver_no = 202302
  AND A.univ_code RLIKE 'X';

SELECT '学科'                           平台,
       A.dtl_id,
       A.var_code,
       B.name,
       A.ver_no,
       A.lev,
       A.val,
       A.subj_code,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2,
       A.detail ->> '$.remark2'       remark3,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.talent_code                  人才代码或专业代码
FROM spm_details_0208.var_detail A
         LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
WHERE _eversions_ = '202302'
  AND univ_code RLIKE 'X';


# 拉取平台内基地和教育部工信部基金项目的变量明细数据（360和学科平台均存在的变量，优先拉取学科平台的变量明细）
SELECT 360                            平台,
       A.dtl_id,
       A.var_code,
       B.name,
       A.ver_no,
       A.lev,
       A.val,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.rel_code                     人才代码或专业代码
FROM ub_details_0429.var_detail A
         LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
WHERE A._r_ver_no = 202302
  AND A.var_code IN (
                     'fwsh001',
                     'fwsh002',
                     'fwsh003',
                     'fwsh004',
                     'fwsh006'
    );

SELECT '学科'                           平台,
       A.dtl_id,
       A.var_code,
       B.name,
       A.ver_no,
       A.lev,
       A.val,
       A.subj_code,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2,
       A.detail ->> '$.remark2'       remark3,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.talent_code                  人才代码或专业代码
FROM spm_details_0208.var_detail A
         LEFT JOIN spm_details_0208.variable B ON A.var_code = B.code
WHERE _eversions_ = '202302'
  AND A.var_code IN (
                     'd11',
                     'd12',
                     'd13',
                     'd14',
                     'd15',
                     'd16',
                     'd17',
                     'd18',
                     'd19',
                     'd2',
                     'd20',
                     'd21',
                     'd3',
                     'd55',
                     'd57',
                     'd58',
                     'd59',
                     'd60',
                     'd61',
                     'd62',
                     'add1057',
                     'pt5',
                     'pt6',
                     'moeyw',
                     'jcgg1',
                     'jcjsjd1',
                     'mathctr',
                     'pt1',
                     'd1',
                     'd56',
                     'd52',
                     'd22',
                     'd51',
                     'd53',
                     'd54',
                     'x15',
                     'c113',
                     'c114',
                     'c115',
                     'west2',
                     'o11',
                     'p10',
                     'x16',
                     'x41',
                     'x42'
    );



# 这是新补充的一批集成电路的学科点、以及各学校能够划到集成电路的老师清单。
# 1、请将平台上这些老师相关的明细拉取出来，交予研究团队进行校验。
# 2、若研究团队校验无误，则需要将这些数据上到平台。
SELECT A.dtl_id,
       A.univ_code,
       A.var_code,
       C.name                         var_name,
       A.ver_no,
       A.lev,
       A.val,
       A.subj_code,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2,
       A.detail ->> '$.remark2'       remark3,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.talent_code                  人才代码或专业代码
FROM spm_details_0208.var_detail A
         JOIN ub_details_raw.cut_detail_data B
              ON A.var_code = B.var_code AND A.ver_no = B.ver_no AND A.talent_code = B.talent_code AND B.is_use = '可用'
    LEFT JOIN spm_details_0208.variable C ON A.var_code = C.code
WHERE A._eversions_ = '202302'
  AND A.univ_code != 'XXXXX'
  AND A.subj_code != ''
  AND A.subj_code != '1401'
  AND A.subj_code != '1402'
  AND A.deleted_at IS NULL
GROUP BY A.dtl_id;


# 拉取360和学科平台下各个变量的非本科学校的明细

SELECT A.dtl_id,
       A.var_code,
       C.name var_name,
       A.univ_code,
       A.ver_no,
       A.lev,
       A.val,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.rel_code                     `talent_code/major_code`,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2
FROM ub_details_0429.var_detail A
         JOIN ub_details_0429.variable C ON A.var_code = C.code
WHERE NOT EXISTS(SELECT *
                 FROM univ_ranking_dev.univ_cn B
                 WHERE A.univ_code = B.code
                   AND B.outdated = 0
                   AND B.univ_level = 1)
  AND A._r_ver_no = 202302
  AND A.var_code IN (
                     'add1049',
                     'r85',
                     'r83',
                     'add1048',
                     'r84',
                     'oto5',
                     'j22',
                     'add1047',
                     'add1055',
                     'j21',
                     'r81',
                     'add1051',
                     'r22',
                     'r82',
                     'add1050',
                     'j23',
                     'oto11',
                     'add1054',
                     'add1046',
                     'oto2',
                     'oto3',
                     'oto6',
                     'oto7',
                     'jygz001',
                     'oto1',
                     'add1053',
                     'oto8',
                     'oto9',
                     'oto10',
                     'oto4',
                     'add1058',
                     'add1059',
                     'bbzq02',
                     'dj1',
                     'sizeng01',
                     'sizeng08',
                     'sizeng09',
                     'sizeng10',
                     'add1060',
                     'sizeng14',
                     'sizeng15',
                     'sizeng17',
                     'oto12',
                     'sizeng02',
                     'sizeng03',
                     'sizeng04',
                     'sizeng05',
                     'sizeng06',
                     'sizeng07',
                     'sizeng11',
                     'sizeng12',
                     'sizeng16',
                     'g4',
                     'jc01',
                     'jc02',
                     'r11',
                     'd22',
                     'd51',
                     'd52',
                     'd53',
                     'd54',
                     'g1',
                     'b66',
                     'b67',
                     'b68',
                     'd11',
                     'd12',
                     'd13',
                     'd14',
                     'd15',
                     'd16',
                     'd17',
                     'd18',
                     'd19',
                     'd2',
                     'd20',
                     'd21',
                     'd3',
                     'd55',
                     'd57',
                     'd58',
                     'd59',
                     'd60',
                     'd61',
                     'd62',
                     'fwsh001',
                     'patent3',
                     'patent1',
                     'patent5',
                     'patent7',
                     'patent9',
                     'patent11',
                     'p2',
                     'p3',
                     'p13',
                     'p11',
                     'p6',
                     'p7',
                     'x16',
                     'p8',
                     'p9',
                     'add7',
                     'x41',
                     'x42',
                     'x15',
                     'c113',
                     'c114',
                     'c115',
                     'b11',
                     'b43',
                     'west1',
                     'add1111',
                     'add1056',
                     'add27',
                     'add1',
                     'add2',
                     'add6',
                     'add3',
                     'x3',
                     'add5',
                     'j10',
                     'z1',
                     'z3',
                     'z2',
                     'j3',
                     'z4',
                     'g11',
                     'g12',
                     'g13',
                     'g14',
                     'g15',
                     'g16',
                     'r11',
                     'doct2',
                     'doct3',
                     'add1057',
                     'pt5',
                     'pt6',
                     'moeyw',
                     'jcgg1',
                     'jcjsjd1',
                     'mathctr',
                     'fwsh002',
                     'fwsh003',
                     'fwsh004',
                     'pt1',
                     'fwsh006',
                     'r4',
                     'r1',
                     'r2',
                     'r17',
                     'r5',
                     'r7',
                     'o12',
                     'bbzq01',
                     'g6',
                     'g5',
                     'g3',
                     'kc5',
                     'add29',
                     'add33',
                     'add34',
                     'add35',
                     'add36',
                     'j13',
                     'j1',
                     'add41',
                     'j7',
                     'j5',
                     'j4',
                     'j8',
                     'j6',
                     'j9',
                     'j12',
                     'j11',
                     'add1010',
                     'add1011',
                     'add1012',
                     'add1013',
                     'add1015',
                     'sz333',
                     'sz334',
                     'sz335',
                     'sz336',
                     'sz337',
                     'sz344',
                     'sz4',
                     'sz8',
                     'sz338',
                     'sz339',
                     'o13',
                     'sz7',
                     'sz10',
                     'sz6',
                     'sz9',
                     'sz3',
                     'add1061',
                     'p5',
                     'x21',
                     'x22',
                     'x24',
                     'x25',
                     'x26',
                     'x23',
                     'x27',
                     'west2',
                     'o11',
                     'cjg1',
                     'dmy1'
    );



SELECT A.dtl_id,
       A.var_code,
       C.name var_name,
       A.univ_code,
       A.ver_no,
       A.lev,
       A.val,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.subj_code,
       A.detail ->> '$.project_money' project_money,
       A.talent_code                  `talent_code/major_code`,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2
FROM spm_details_0208.var_detail A
         JOIN spm_details_0208.variable C ON A.var_code = C.code
WHERE NOT EXISTS(SELECT *
                 FROM univ_ranking_dev.univ_cn B
                 WHERE A.univ_code = B.code
                   AND B.outdated = 0
                   AND B.univ_level = 1)
  AND A._eversions_ = '202302'
  AND A.var_code IN (
                     'add1049',
                     'r85',
                     'r83',
                     'add1048',
                     'r84',
                     'oto5',
                     'j22',
                     'add1047',
                     'add1055',
                     'j21',
                     'r81',
                     'add1051',
                     'r22',
                     'r82',
                     'add1050',
                     'j23',
                     'oto11',
                     'add1054',
                     'add1046',
                     'oto2',
                     'oto3',
                     'oto6',
                     'oto7',
                     'jygz001',
                     'oto1',
                     'add1053',
                     'oto8',
                     'oto9',
                     'oto10',
                     'oto4',
                     'add1058',
                     'add1059',
                     'bbzq02',
                     'dj1',
                     'sizeng01',
                     'sizeng08',
                     'sizeng09',
                     'sizeng10',
                     'add1060',
                     'sizeng14',
                     'sizeng15',
                     'sizeng17',
                     'oto12',
                     'sizeng02',
                     'sizeng03',
                     'sizeng04',
                     'sizeng05',
                     'sizeng06',
                     'sizeng07',
                     'sizeng11',
                     'sizeng12',
                     'sizeng16',
                     'g4',
                     'jc01',
                     'jc02',
                     'r11',
                     'd22',
                     'd51',
                     'd52',
                     'd53',
                     'd54',
                     'g1',
                     'b66',
                     'b67',
                     'b68',
                     'd11',
                     'd12',
                     'd13',
                     'd14',
                     'd15',
                     'd16',
                     'd17',
                     'd18',
                     'd19',
                     'd2',
                     'd20',
                     'd21',
                     'd3',
                     'd55',
                     'd57',
                     'd58',
                     'd59',
                     'd60',
                     'd61',
                     'd62',
                     'fwsh001',
                     'patent3',
                     'patent1',
                     'patent5',
                     'patent7',
                     'patent9',
                     'patent11',
                     'p2',
                     'p3',
                     'p13',
                     'p11',
                     'p6',
                     'p7',
                     'x16',
                     'p8',
                     'p9',
                     'add7',
                     'x41',
                     'x42',
                     'x15',
                     'c113',
                     'c114',
                     'c115',
                     'b11',
                     'b43',
                     'west1',
                     'add1111',
                     'add1056',
                     'add27',
                     'add1',
                     'add2',
                     'add6',
                     'add3',
                     'x3',
                     'add5',
                     'j10',
                     'z1',
                     'z3',
                     'z2',
                     'j3',
                     'z4',
                     'g11',
                     'g12',
                     'g13',
                     'g14',
                     'g15',
                     'g16',
                     'r11',
                     'doct2',
                     'doct3',
                     'add1057',
                     'pt5',
                     'pt6',
                     'moeyw',
                     'jcgg1',
                     'jcjsjd1',
                     'mathctr',
                     'fwsh002',
                     'fwsh003',
                     'fwsh004',
                     'pt1',
                     'fwsh006',
                     'r4',
                     'r1',
                     'r2',
                     'r17',
                     'r5',
                     'r7',
                     'o12',
                     'bbzq01',
                     'g6',
                     'g5',
                     'g3',
                     'kc5',
                     'add29',
                     'add33',
                     'add34',
                     'add35',
                     'add36',
                     'j13',
                     'j1',
                     'add41',
                     'j7',
                     'j5',
                     'j4',
                     'j8',
                     'j6',
                     'j9',
                     'j12',
                     'j11',
                     'add1010',
                     'add1011',
                     'add1012',
                     'add1013',
                     'add1015',
                     'sz333',
                     'sz334',
                     'sz335',
                     'sz336',
                     'sz337',
                     'sz344',
                     'sz4',
                     'sz8',
                     'sz338',
                     'sz339',
                     'o13',
                     'sz7',
                     'sz10',
                     'sz6',
                     'sz9',
                     'sz3',
                     'add1061',
                     'p5',
                     'x21',
                     'x22',
                     'x24',
                     'x25',
                     'x26',
                     'x23',
                     'x27',
                     'west2',
                     'o11',
                     'cjg1',
                     'dmy1'
    );



SELECT A.dtl_id,
       A.var_code,
       C.name                         var_name,
       A.univ_code,
       A.ver_no,
       A.lev,
       A.val,
       A.detail ->> '$.award_level'   award_level,
       A.detail ->> '$.talent_name'   talent_name,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.rel_code                     `talent_code/major_code`,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2
FROM ub_details_0429.var_detail A
         JOIN ub_details_0429.variable C ON A.var_code = C.code
WHERE A._r_ver_no = 202302
  AND A.deleted_at IS NULL
  AND A.var_code IN (
                     'jc03',
                     'jc01',
                     'jc02',
                     'd22',
                     'd51',
                     'd52',
                     'd53',
                     'd54',
                     'add1046',
                     'add1047',
                     'add1048',
                     'add1049',
                     'add1050',
                     'add1051',
                     'add1053',
                     'add1054',
                     'add1055',
                     'j21',
                     'j22',
                     'j23',
                     'jygz001',
                     'oto1',
                     'oto10',
                     'oto11',
                     'oto2',
                     'oto3',
                     'oto4',
                     'oto5',
                     'oto6',
                     'oto7',
                     'oto8',
                     'oto9',
                     'r22',
                     'r81',
                     'r82',
                     'r83',
                     'r84',
                     'r85',
                     'add1058',
                     'add1059',
                     'bbzq02',
                     'dj1',
                     'oto12'
    );





# 应研究部需求，需导出学科平台中Nature论文和Science论文的部分高校明细数据
SELECT var_code `N/S`,
       detail ->> '$.elected_code'                                               学校代码,
       detail ->> '$.elected_name'                                               学校名称,
       ver_no                                                                    年份,
       detail ->> '$.project_name'                                               篇名,
       IF(detail ->> '$.author_first' = 'null', '', detail ->> '$.author_first') 第一作者,
       detail ->> '$.author_corresponding'                                       通讯作者,
       detail ->> '$.doi_no'                                                     DOI号,
       detail ->> '$.subject_code'                                               学科
FROM spm_details_0208.var_detail
WHERE _eversions_ = '202302'
  AND var_code IN ('nature', 'science')
  AND ver_no >= 2013
  AND detail ->> '$.elected_code' IN (
                                      'RC00001',
                                      'RC00002',
                                      'RC00013',
                                      'RC00036',
                                      'RC00034',
                                      'RC00004',
                                      'RC00005',
                                      'RC00009',
                                      'RC00003',
                                      'RC00006'
    );


# 拉取学生相关数据
SELECT A.ind_code,
       A.univ_code,
       A.target_ver,
       A.effect_ver,
       (SELECT GROUP_CONCAT(B.name ORDER BY FIND_IN_SET(B.id, A.eff_src_ids))
        FROM ub_details_0429.var_detail_source B
        WHERE FIND_IN_SET(B.id, A.eff_src_ids)) eff_src_names,
       A.eff_src_ids,
       A.val,
       A.alt_val
FROM ub_ranking_dev.ind_value_latest A
WHERE A.ind_code IN (SELECT code
                     FROM ub_ranking_dev.indicator_latest
                     WHERE level = 3
                       AND name IN ('学生总数', '本科生数', '硕士生数', '博士生数', '研究生数', '留学生数', '专科生数'))
  AND effect_ver IN (2020, 2021)
  AND alt_val IS NULL
ORDER BY ind_code, target_ver, univ_code;





# 杨老师需要的省份数据-生产环境
/*SELECT D.name                 省份,
       A.ind_code             指标代码,
       B.name                 指标名称（360）,
       A.target_ver           默认监测年份（360）,
       SUM(A.val)             数据值,
       B.val ->> '$.unitCode' 数据单位
FROM ub_ranking_a.ind_value_latest A
         JOIN ub_ranking_a.indicator_latest B ON A.ind_code = B.code AND A.target_ver = B.detail ->> '$.targetVer'
         JOIN univ_ranking_a.univ_cn C ON A.univ_code = C.code
         JOIN univ_ranking_a.gi_province D ON C.province_code = D.code
WHERE B.name IN (
                 '中国科学院院士',
                 '中国工程院院士',
                 '科研平台（折合数）',
                 '自科面上青年项目（总数）',
                 '社科一般青年项目（总数）',
                 '自科重大项目（总额）',
                 '社科重大项目（折合数）',
                 '国家重大奖励（折合数）',
                 '教育部奖励（折合数）',
                 '思政课程名师（折合数）',
                 '思政教育队伍（折合数）',
                 '思政教育基地（折合数）',
                 '模范先进教师（折合数）',
                 '模范先进学生（折合数）',
                 '国家级与认证专业（总数）',
                 '国家一流本科课程（总数）',
                 '国家教学基地（折合数）',
                 '国家教学成果奖（折合数）',
                 '研究生教育成果奖（折合数）',
                 '科创竞赛奖（折合数）',
                 '国内顶尖学科（软科前2%）',
                 '国内一流学科（软科前10%）',
                 '国内优势学科（软科前50%）',
                 '国际顶尖学科（软科前50名）',
                 '国际一流学科（软科上榜）',
                 'ESI前万分之一学科数',
                 'ESI前千分之一学科数',
                 'ESI前百分之一学科数'
    )
  AND B.level = 3
  AND C.outdated = 0
  AND B.code != 'cate050881'
GROUP BY D.name, A.ind_code
ORDER BY D.name, A.ind_code;*/



/*SELECT A.univ_code            学校代码,
       C.name_cn              学校名称,
       D.name                 省份,
       A.ind_code             指标代码,
       B.name                 指标名称（360）,
       A.target_ver           默认监测年份（360）,
       A.val                  数据值,
       B.val ->> '$.unitCode' 数据单位
FROM ub_ranking_a.ind_value_latest A
         JOIN ub_ranking_a.indicator_latest B ON A.ind_code = B.code AND A.target_ver = B.detail ->> '$.targetVer'
         JOIN univ_ranking_a.univ_cn C ON A.univ_code = C.code
         JOIN univ_ranking_a.gi_province D ON C.province_code = D.code
WHERE B.name IN (
                 '中国科学院院士',
                 '中国工程院院士',
                 '科研平台（折合数）',
                 '自科面上青年项目（总数）',
                 '社科一般青年项目（总数）',
                 '自科重大项目（总额）',
                 '社科重大项目（折合数）',
                 '国家重大奖励（折合数）',
                 '教育部奖励（折合数）',
                 '思政课程名师（折合数）',
                 '思政教育队伍（折合数）',
                 '思政教育基地（折合数）',
                 '模范先进教师（折合数）',
                 '模范先进学生（折合数）',
                 '国家级与认证专业（总数）',
                 '国家一流本科课程（总数）',
                 '国家教学基地（折合数）',
                 '国家教学成果奖（折合数）',
                 '研究生教育成果奖（折合数）',
                 '科创竞赛奖（折合数）',
                 '国内顶尖学科（软科前2%）',
                 '国内一流学科（软科前10%）',
                 '国内优势学科（软科前50%）',
                 '国际顶尖学科（软科前50名）',
                 '国际一流学科（软科上榜）',
                 'ESI前万分之一学科数',
                 'ESI前千分之一学科数',
                 'ESI前百分之一学科数'
    )
  AND B.level = 3
  AND C.outdated = 0
  AND B.code != 'cate050881'
ORDER BY D.name, A.ind_code;*/



SELECT *
FROM spm_details_0208.var_detail A
         JOIN ub_details_raw.test_project_name_2 B ON A.detail ->> '$.project_name' RLIKE B.project_name
WHERE _eversions_ = '202302'
  AND var_code = 'p5';


# 哈工大nature和science论文数全部年份（2011-2021）的数据
SELECT var_code                            论文,
       ver_no                              年份,
       detail ->> '$.elected_name'         学校,
       detail ->> '$.project_name'         篇名,
       detail ->> '$.remark1'              期刊来源,
       detail ->> '$.volume'               卷,
       detail ->> '$.issue'                期,
       detail ->> '$.doi_no'               DOI号,
       detail ->> '$.author_first'         第一作者,
       detail ->> '$.author_corresponding' 通讯作者,
       subj_code                           学科
FROM spm_details_0208.var_detail
WHERE _eversions_ = '202302'
  AND univ_code = 'RC00008'
  AND var_code IN ('nature', 'science');


# 360平台2020-2020各学校排名数据
# 大学排名
SELECT A.yr           年份,
       C.name         排名类型,
       A.univ_code    学校代码,
       B.name_cn      学校名称,
       A.ranking      排名,
       A.rank_overall '总榜排名(某些排名的参考排名)',
       rank_category  '分类排名(分榜)'
FROM univ_ranking_dev.bcur_rank A
         LEFT JOIN univ_ranking_dev.univ_cn B ON A.univ_cn_id = B.id
         LEFT JOIN univ_ranking_dev.code_bcur_type C ON A.type_id = C.id
WHERE 1
ORDER BY yr,(ranking + 0);

# 模块得分
SELECT A.yr              年份,
       C.name            排名类型,
       A.univ_code       学校代码,
       B.name_cn         学校名称,
       D.name            模块,
       A.score           得分,
       A.score___precise 精确得分
FROM univ_ranking_dev.bcur_ind_rank A
         LEFT JOIN univ_ranking_dev.univ_cn B ON A.univ_cn_id = B.id
         LEFT JOIN univ_ranking_dev.code_bcur_type C ON A.type_id = C.id
         LEFT JOIN univ_ranking_dev.bcur_indicator D ON A.ind_id = D.id AND A.yr = D.yr
WHERE 1
ORDER BY A.yr, (A.ranking + 0);


# 麻烦协助提供360平台里双一流高校的两个指标数据：硕士点数（2021）、专任教师数（2021）
# 1）如2021年数据暂无，无需反馈前一年数据，直接空白处理即可
# 2）学校名称可脱密处理

SELECT A.univ_code 学校代码,
       B.name 指标,
       A.effect_ver 年份,
       A.val 数值
FROM ub_ranking_dev.ind_value_latest A
         JOIN ub_ranking_dev.indicator_latest B ON A.ind_lat_id = B.id AND A.target_ver = B.detail ->> '$.targetVer'
         JOIN univ_ranking_dev.univ_cn C ON A.univ_code = C.code
WHERE B.name IN ('教师规模', '硕士点数')
  AND B.level = 3
  AND A.target_ver = effect_ver
  AND C.outdated = 0
  AND C.is_fcu = 1
ORDER BY 指标,学校代码,数值 DESC;




# 专业平台计算规则重构，需要整理学校层面的变量替代值数据，麻烦拉取以下变量的明细数据：
# 1、生均经费    2021
# 2、学校收入（总额）  2021
# 3、本科生数   2021
# 4、教师规模   2021
# 5、师生比   2021
# 6、教师学历结构  2021
# 7、教师职称结构  2021
# 8、教授授课率  2021
# 9、本科毕业生就业率（按专业采集）2021 （无）
# 10、本科毕业生就业率（学校层面）2021
# 11、新生高考成绩    2020（无）

SELECT A.univ_code                              学校代码,
       C.name_cn                                学校名称,
       B.code                                   指标代码,
       B.name                                   指标名称,
       A.target_ver                             监测年份,
       A.val                                    指标数值,
       (SELECT GROUP_CONCAT(D.name ORDER BY FIND_IN_SET(D.id, A.eff_src_ids))
        FROM ub_details_0429.var_detail_source D
        WHERE FIND_IN_SET(D.id, A.eff_src_ids)) 来源名称,
       A.alt_val                                替代值,
       B.val ->> '$.unitCode'                   单位
FROM ub_ranking_dev.ind_value_latest A
         LEFT JOIN ub_ranking_dev.indicator_latest B
                   ON A.ind_code = B.code AND A.target_ver = B.detail ->> '$.targetVer'
         LEFT JOIN univ_ranking_dev.univ_cn C ON A.univ_code = C.code AND C.outdated = 0
WHERE B.level = 3
  AND B.deleted_at IS NULL
  AND B.name IN (
                 '学校收入（生均）', '学校收入（总额）', '本科生数',
                 '教师规模', '师生比', '教师学历结构（博士学位教师占比）',
                 '教师职称结构（高级职称教师占比）', '教授授课率',
                 '本科毕业生就业率'
    )
ORDER BY B.pid, B.ord_no;




# 兰涛数据需求
SELECT 360                            product,
       A.dtl_id,
       A.var_code,
       B.name                         var_name,
       A.ver_no                       yr,
       A.detail ->> '$.award_level'   award_level,
       A.lev,
       A.val,
       A.detail ->> '$.talent_name'   talent_name,
       A.rel_code                     talent_code,
       A.detail ->> '$.born_year'     born_year,
       A.detail ->> '$.dead_year'     born_year,
       A.detail ->> '$.current_code'  current_code,
       A.detail ->> '$.current_name'  current_name,
       A.detail ->> '$.elected_code'  elected_code,
       A.detail ->> '$.elected_name'  elected_name,
       A.detail ->> '$.elected_year'  elected_year,
       A.detail ->> '$.project_name'  project_name,
       A.detail ->> '$.project_money' project_money,
       A.detail ->> '$.remark1'       remark1,
       A.detail ->> '$.remark2'       remark2,
       A.detail ->> '$.remark3'       remark3
FROM ub_details_0429.var_detail A
         LEFT JOIN ub_details_0429.variable B ON A.var_code = B.code
WHERE A._r_ver_no = 202302
  AND A.var_code IN ('p11', 'p11_1', 'p11_2', 'p11_3');
















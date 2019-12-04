DROP MATERIALIZED VIEW IF EXISTS sepsis_dm;
CREATE MATERIALIZED VIEW sepsis_dm AS
(
select sepsis.*, diag_dm.dm
from sepsis
       left join (select subject_id,
                         hadm_id,
                         MAX(
                                 CASE
                                   WHEN icd9_code in (
                                     select icd9_code
                                     from d_icd_diagnoses
                                     where (lower(short_title) like '%diabetes%'
                                       or lower(long_title) like '%diabetes%')
                                       and icd9_code not in
                                           ('2535', '5881', 'V771', 'V180', 'V1221', '64800', '64801',
                                            '64802',
                                            '64803', '64804'))
                                     THEN 1
                                   ELSE 0 END) as dm
                  from diagnoses_icd
                  group by subject_id, hadm_id) as diag_dm on sepsis.hadm_id = diag_dm.hadm_id);
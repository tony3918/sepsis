select subject_id
from sepsis
group by subject_id
having count(*) > 1;

select *
from sepsis;
select count(*)
from martin_sepsis;

select *
from admissions
where subject_id in (select subject_id from sepsis);

select *
from diagnoses_icd
where subject_id = 23680;

select count(*)
from chartevents
where subject_id = 3;

-- select * from d_items where abbreviation NOTNULL;
select *
from d_items
where lower(label) like '%glucose%'
   or lower(label) like '%finger%';

select icd9_code
from diagnoses_icd;
select *
from d_icd_diagnoses
where (lower(short_title) like '%diabetes%'
    or lower(long_title) like '%diabetes%')
  and icd9_code not in ('2535', '5881', 'V771', 'V180', 'V1221', '64800', '64801', '64802', '64803', '64804');

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

select *
from chartevents
where itemid = 1845;

select *
from d_icd_diagnoses
where (lower(short_title) like '%diabetes%'
    or lower(long_title) like '%diabetes%')
  and icd9_code not in
      ('2535', '5881', 'V771', 'V180', 'V1221', '64800', '64801',
       '64802',
       '64803', '64804');


CREATE OR REPLACE FUNCTION search_diagnoses(query VARCHAR)
    RETURNS TABLE
            (
                icd9_code   int,
                short_title text,
                long_title  text
            )
AS
$$
BEGIN
    RETURN QUERY SELECT d.icd9_code as icd9_code, d.short_title as short_title, d.long_title as long_title
                 from d_icd_diagnoses d
                 where lower(short_title) LIKE '%' || query || '%'
                    or lower(long_title) LIKE '%' || query || '%';
END;
$$
    LANGUAGE 'plpgsql';

select *
from d_icd_diagnoses
where short_title like '%' || 'diabetes' || '%';

select *
from search_diagnoses('diabetes')
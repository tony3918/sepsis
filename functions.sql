DROP FUNCTION IF EXISTS search_diagnoses(query VARCHAR);
CREATE OR REPLACE FUNCTION search_diagnoses(query VARCHAR)
  RETURNS TABLE
          (
            icd9_code   varchar(10),
            short_title varchar(50),
            long_title  varchar(255)
          )
AS
$$
BEGIN
  RETURN QUERY SELECT d.icd9_code, d.short_title, d.long_title
               from d_icd_diagnoses d
               where lower(d.short_title) LIKE '%' || query || '%'
                  or lower(d.long_title) LIKE '%' || query || '%';
END;
$$
  LANGUAGE 'plpgsql';

-- select *
-- from search_diagnoses('diabetes')


DROP FUNCTION IF EXISTS search_items(query VARCHAR);
CREATE OR REPLACE FUNCTION search_items(query VARCHAR)
  RETURNS TABLE
          (
            itemid   integer,
            label    varchar(200),
            unitname varchar(100),
            dbsource varchar(20),
            category varchar(100),
            linksto  varchar(50)
          )
AS
$$
BEGIN
  RETURN QUERY SELECT d.itemid, d.label, d.unitname, d.dbsource, d.category, d.linksto
               from d_items d
               where lower(d.label) like '%' || query || '%';
END
$$
  LANGUAGE 'plpgsql';

-- select *
-- from search_items('alt');

DROP FUNCTION IF EXISTS fill_column(VARIADIC arr integer[]);
CREATE OR REPLACE FUNCTION fill_column(VARIADIC arr integer[])
  RETURNS TABLE
          (
            hadm_id integer,
            value   text
          )
AS
$$
BEGIN
  RETURN QUERY select i.hadm_id, (case when i.value IS NOT NULL then text(i.value) ELSE text(i.valuenum) end) as value
               from (select s.hadm_id,
                            ce.charttime,
                            ce.value,
                            ce.valuenum,
                            row_number() over (partition by s.hadm_id order by ce.charttime ) as rank
                     from sepsis_dm s
                            left join chartevents ce on s.hadm_id = ce.hadm_id
                     where ce.itemid = any (arr)) i
               where i.rank = 1
                 and (i.value IS NOT NULL OR i.valuenum IS NOT NULL);
END
$$
  LANGUAGE 'plpgsql';

-- select *
-- from fill_column(770, 3801, 220587);
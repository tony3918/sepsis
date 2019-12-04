select count(*)
from sepsis_dm;

select s.*, ast.value as ast, alt.value as alt
from sepsis_dm s
       left join (select *
                  from fill_column(770, 3801, 220587)) ast on s.hadm_id = ast.hadm_id
       left join (select *
                  from fill_column(769, 3802, 1286, 220644)) alt on s.hadm_id = alt.hadm_id;

select *
from fill_column(1127, 861, 4200, 1542, 3832, 227062, 220546, 226780)
order by value desc;

select i.hadm_id,
       date_part('day', i.charttime - i.admittime) * 24 +
       date_part('hour', i.charttime - i.admittime)                                 as measurement_delay,
       (case when i.value IS NOT NULL then text(i.value) ELSE text(i.valuenum) end) as value
from (select s.hadm_id,
             a.admittime,
             ce.charttime,
             ce.value,
             ce.valuenum,
             row_number() over (partition by s.hadm_id order by ce.charttime ) as rank
      from sepsis_dm s
             left join chartevents ce on s.hadm_id = ce.hadm_id
             left join admissions a on ce.hadm_id = a.hadm_id
      where ce.itemid = any (array [1127, 861, 4200, 1542, 3832, 227062, 220546, 226780])) i
where i.rank = 1
  and (i.value IS NOT NULL OR i.valuenum IS NOT NULL);



select *
from chartevents
where hadm_id = 100206
  and itemid = any (array [1127, 861, 4200, 1542, 3832, 227062, 220546, 226780])
order by charttime;

select *
from admissions
where hadm_id = 100206;
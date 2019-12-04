select itemid, charttime, value, valuenum, valueuom
from chartevents
where itemid = 226762;
select count(*)
from chartevents
where itemid = 226762;

select *
from search_items('crit');

select *
from search_diagnoses('diabetes')
2. Распределение количества дней между последовательными визитами для каждого person_id к каждому provider_id за всё время

***
diff_btwn_dates - промежуток в днях между приемами
count(*) as cnt - количество раз, сколько данный промежуток встречался

1. подзапрос proc_occ - удаляем дубли (person_id, provider_id, procedure_dat)
2. подзапрос sub_q1 - добавляем:
	prev_date - предыдущая дата приема,
	diff_btwn_dates - разница в днях между предыдущим приемом и датой приема в текущей строке

***


SELECT 
	person_id, 
	provider_id, 
	diff_btwn_dates,
	count(*) as cnt

FROM
(SELECT 
   person_id, 
   provider_id,
   procedure_dat,
   lag(procedure_dat) OVER(
      partition by person_id, provider_id order by procedure_dat ASC
   ) as prev_date,
   date_diff(procedure_dat,  lag(procedure_dat) OVER(
      partition by person_id, provider_id order by procedure_dat ASC
   ),day) as diff_btwn_dates
FROM 
(SELECT 
   DISTINCT person_id, 
   provider_id,
   procedure_dat
FROM
  `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence`) AS proc_occ
--WHERE person_id =11 and provider_id = 307
ORDER BY 
   person_id, 
   provider_id,
   procedure_dat asc
) AS sub_q1
WHERE diff_btwn_dates is not null
GROUP BY person_id, 
         provider_id, 
         diff_btwn_dates
ORDER BY person_id, 
         provider_id, 
         diff_btwn_dates asc

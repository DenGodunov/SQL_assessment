4. Посчитать за каждый год процент новых person_id и процент ушедших person_id. 
Под ушедшим person_id понимается person_id, который был в году Y - 1, но у него нет ни одной записи в году Y. Под новым понимается person_id, которого нет в году Y - 1, но есть в году Y
***
1. подзапрос proc_occ - удаляем дубли (person_id, provider_id, procedure_dat)
2. sub_q1 - для каждого person_id вычисляем:
y_2007 - была ли хоть одна запись у данного person_id в 2007
y_2008 - была ли хоть одна запись в 2008
y_2009 - была ли хоть одна запись в 2009
y_2010 - была ли хоть одна запись в 2010
3. sub_q2 - для каждого person_id вычисляем:
in2008 - если у person_id не было записей в 2007 но были в 2008 то 1 иначе 0 (пришедший 2008)
out2008 - если у person_id были записи в 2007 но не было в 2008 то 1 иначе 0 (ушедший 2008)
in2009 - если у person_id не было записей в 2008 но были в 2009 то 1 иначе 0 (пришедший 2009)
out2009 - если у person_id были записи в 2008 но не было в 2009 то 1 иначе 0 (ушедший 2009)
in2010 - если у person_id не было записей в 2009 но были в 2010 то 1 иначе 0 (пришедший 2010)
out2010 если у person_id были записи в 2009 но не было в 2010 то 1 иначе 0 (ушедший 2010)
4. sub_q3 - суммируем ушедших и пришедщих за 2008, 2009, 2010


***

SELECT 
	in_2008,
	out_2008,
	in_2009,
	ROUND(((in_2009 - in_2008)/in_2008* 100),2) as in_2009_prcnt,
	out_2009,
	ROUND(((out_2009 - out_2008)/out_2008* 100),2) as out_2009_prcnt,
	in_2010,
	ROUND(((in_2010 - in_2009)/in_2009* 100),2) as in_2010_prcnt,
	out_2010,
	ROUND(((out_2010 - out_2009)/out_2009* 100),2) as out_2010_prcnt
FROM
	(SELECT 
		SUM(in2008) AS in_2008,
		SUM(out2008) AS out_2008,
		SUM(in2009) AS in_2009,
		SUM(out2009) AS out_2009,
		SUM(in2010) AS in_2010,
		SUM(out2010) AS out_2010
	FROM (
		SELECT 
			person_id,
			case 
			when y_2007 = 0 and y_2008 = 1 then  1 else 0 end as in2008, 
			case 
			when y_2007 = 1 and y_2008 = 0 then 1 else 0 end as out2008,

			case 
			when y_2008 = 0 and y_2009 = 1 then  1 else 0 end as in2009, 
			case 
			when y_2008 = 1 and y_2009 = 0 then 1 else 0 end as out2009,
			case 
			when y_2009 = 0 and y_2010 = 1 then  1 else 0 end as in2010, 
			case 
			when y_2009 = 1 and y_2010 = 0 then 1 else 0 end as out2010


		FROM (
			SELECT 
				DISTINCT
				person_id, 
				case 
					when 
					exists(select * from  `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence` where EXTRACT(YEAR FROM  procedure_dat) = 2007 and person_id = proc_occ.person_id) then 1
				else 0
				end as y_2007,
				case 
					when 
					exists(select * from  `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence` where EXTRACT(YEAR FROM  procedure_dat) = 2008 and person_id = proc_occ.person_id) then 1
				else 0
				end as y_2008,
				case 
					when 
					exists(select * from  `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence` where EXTRACT(YEAR FROM  procedure_dat) = 2009 and person_id = proc_occ.person_id) then 1
				else 0
				end as y_2009,
				case 
					when 
					exists(select * from  `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence` where EXTRACT(YEAR FROM  procedure_dat) = 2010 and person_id = proc_occ.person_id) then 1
				else 0
				end AS y_2010
			FROM 
				(
				SELECT 
				   DISTINCT 
				   person_id,
				   procedure_dat
				FROM  `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence`
				) AS proc_occ
			--where person_id in (715022,13,715023, 1002126)
			) AS sub_q1
		) AS sub_q2
	) AS sub_q3
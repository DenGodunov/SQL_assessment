3. Вывести топ-3 provider_id для каждого person_id по количеству визитов за всё время
***
1. подзапрос proc_occ - удаляем дубли (person_id, provider_id, procedure_dat)
2. sub_q1 - добавляем proc_cnt - количество записей для каждой комбинации person_id + provider_id
3. sub_q2 - нумеруем все строки для каждого person_id отдельно, в порядке убывания количества записей (procedure_dat) - row_num
row_num in (1,2,3) - оставляем только строки пронумерованные от 1 до 3
Вопрос - если несколько провайдеров имеют одно и тоже количество procedure_dat, то нужно выводить обоих с одинаковым row_num или только одного по какому-то признаку (например того у кого наименьший provider_id)?
***
SELECT 
	person_id,
	provider_id,
	proc_cnt,
	row_num
FROM (
	SELECT 
		person_id,
		provider_id,
		proc_cnt,
		ROW_NUMBER() 
		OVER(partition by person_id order by proc_cnt DESC) AS row_num
	FROM 
		( 
		SELECT
			person_id,
			provider_id,
			count(procedure_dat) as proc_cnt
  
		FROM 
			(SELECT distinct person_id, 
					provider_id,
					procedure_dat
			FROM `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence`
			) AS proc_occ
	--WHERE person_id in (11,13)
	GROUP BY 
		person_id,
		provider_id
		) as sub_q1

	) AS sub_q2
WHERE row_num in (1,2,3)

ORDER BY 
	person_id, 
	proc_cnt DESC
Публичный датасет BigQuery bigquery-public-data:cms_synthetic_patient_data_omop.procedure_occurrence

Задание
!!! Используйте только уникальные сочетания provider_id, person_id, procedure_dat
Подсказки:
- Для более быстрой отладки кода можно использовать подмножество person_id
- Используйте оконные функции»
=====================

1. Вывести первые визиты person_id к provider_id для всех person_id и provider_id пар за всё время
SELECT 
   person_id, 
   provider_id,
   min(procedure_dat) as min_proc_dat
FROM 
  `bigquery-public-data.cms_synthetic_patient_data_omop.procedure_occurrence`

group by person_id, provider_id
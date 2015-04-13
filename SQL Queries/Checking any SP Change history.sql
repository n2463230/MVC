SELECT * FROM tblDBAudit 
WHERE ObjectName LIKE '%proc_Service_ExecutionEngine_GetNextBatchJob%' 
--AND SqlCommand LIKE '%JobFuncitonId%' 
ORDER BY EventDate DESC
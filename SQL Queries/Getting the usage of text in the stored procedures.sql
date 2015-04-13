SELECT OBJECT_SCHEMA_NAME(object_id),
  OBJECT_NAME(object_id)
FROM sys.sql_modules
WHERE [definition] LIKE '%Proc_LogForJobfunction_NdaMailSentHelper%';
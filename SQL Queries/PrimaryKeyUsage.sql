CREATE PROCEDURE proc_GetPrimaryKeyUsageCount (
	@PrimaryKeyColumnId INT
	,@PrimaryKeyTable NVARCHAR(max)
	--,@Response INT OUTPUT  
	)
AS
BEGIN
	DECLARE @counter INT
	DECLARE @sqlCommand NVARCHAR(max)
	DECLARE @ForeignKey TABLE (
		child_table VARCHAR(max)
		,child_fk_column VARCHAR(max)
		)
	DECLARE @child_table VARCHAR(max)
	DECLARE @child_fk_column VARCHAR(max)

	SET @counter = 0

	INSERT INTO @ForeignKey
	SELECT child_table = c.TABLE_NAME
		,child_fk_column = c.COLUMN_NAME
	FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE p
	INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS pc ON pc.UNIQUE_CONSTRAINT_SCHEMA = p.CONSTRAINT_SCHEMA
		AND pc.UNIQUE_CONSTRAINT_NAME = p.CONSTRAINT_NAME
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE c ON c.CONSTRAINT_SCHEMA = pc.CONSTRAINT_SCHEMA
		AND c.CONSTRAINT_NAME = pc.CONSTRAINT_NAME
	WHERE EXISTS (
			SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE COLUMN_NAME = 'IsDeleted'
				AND TABLE_SCHEMA = p.TABLE_SCHEMA
				AND TABLE_NAME = p.TABLE_NAME
				AND p.TABLE_NAME = @PrimaryKeyTable
			)

	DECLARE db_cursor CURSOR
	FOR
	SELECT child_table
		,child_fk_column
	FROM @ForeignKey

	OPEN db_cursor

	FETCH NEXT
	FROM db_cursor
	INTO @child_table
		,@child_fk_column

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'select count(*) from ' + CAST(@child_table AS VARCHAR) + ' where ' + CAST(@child_fk_column AS VARCHAR) + ' = ' + CAST(@PrimaryKeyColumnId AS VARCHAR)

		SET @sqlCommand = 'select @cnt=count(*) from ' + CAST(@child_table AS VARCHAR) + ' where ' + CAST(@child_fk_column AS VARCHAR) + ' = ' + CAST(@PrimaryKeyColumnId AS VARCHAR)

		EXEC sp_executesql @sqlCommand
			,N'@cnt int OUTPUT'
			,@cnt = @counter OUTPUT

		IF @counter > 0
			BREAK

		FETCH NEXT
		FROM db_cursor
		INTO @child_table
			,@child_fk_column
	END

	SELECT @counter AS [PrimaryKeyUsageCount]
END
	--EXEC proc_GetPrimaryKeyUsageCount 41, 'tblAttribute'  

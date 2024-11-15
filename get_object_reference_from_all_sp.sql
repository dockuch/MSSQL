DECLARE @procName NVARCHAR(255);

-- Create a table to store the results
CREATE TABLE #Results (
    originating_procedure_name NVARCHAR(255),
    referenced_server_name NVARCHAR(255),
    referenced_database_name NVARCHAR(255),
    referenced_schema_name NVARCHAR(255),
    referenced_entity_name NVARCHAR(255)
);

-- Cursor to loop through all stored procedures
DECLARE proc_cursor CURSOR FOR
SELECT name
FROM sys.procedures;

OPEN proc_cursor;
FETCH NEXT FROM proc_cursor INTO @procName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert the results of the query into the temporary table
    INSERT INTO #Results
    EXEC sp_executesql N'
        SELECT 
            @_sp AS originating_procedure_name,
            ISNULL(referenced_server_name, ''DB-SQL01'') AS referenced_server_name,
            referenced_database_name,
            referenced_schema_name,
            referenced_entity_name
        FROM sys.dm_sql_referenced_entities(@_sp, ''OBJECT'')',
        N'@_sp NVARCHAR(255)', @procName;

    FETCH NEXT FROM proc_cursor INTO @procName;
END;

CLOSE proc_cursor;
DEALLOCATE proc_cursor;

-- Select the results
SELECT * FROM #Results;

-- Drop the temporary table
DROP TABLE #Results;

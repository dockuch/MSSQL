DECLARE @procName NVARCHAR(255);

-- Create a table to store the results
CREATE TABLE #Results (
    table_name NVARCHAR(255),
    CMMContainer NVARCHAR(255)
);

-- Cursor to loop through all stored procedures
DECLARE proc_cursor CURSOR FOR
select 
	'select distinct '''+t.name+''' as tbl_name, {cmmcontainer} from ' + concat_ws('.', s.name, t.name) + ';' as query
from sys.tables t
	inner join sys.schemas s
		on t.schema_id = s.schema_id
	inner join sys.all_columns ac
		on t.object_id = ac.object_id
where s.name = 'dw' -- schema_name
	and ac.name = 'CMMContainer'; -- column_name

OPEN proc_cursor;
FETCH NEXT FROM proc_cursor INTO @procName;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert the results of the query into the temporary table
    INSERT INTO #Results
    EXEC sp_executesql @procName;

    FETCH NEXT FROM proc_cursor INTO @procName;
END;

CLOSE proc_cursor;
DEALLOCATE proc_cursor;

-- Select the results
SELECT * FROM #Results;

-- Drop the temporary table
DROP TABLE #Results;

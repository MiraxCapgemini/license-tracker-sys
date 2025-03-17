CREATE TRIGGER [dbo].[trg_LicenseVendors_Audit]
ON [dbo].[LicenseVendors]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @OperationDate DATETIME;
    DECLARE @OperationType NVARCHAR(50);
    DECLARE @OldValue NVARCHAR(MAX);
    DECLARE @NewValue NVARCHAR(MAX);
    DECLARE @UserID NVARCHAR(255) = SYSTEM_USER; -- or use SUSER_SNAME() for SQL Server login

    SET @OperationDate = GETDATE();

    -- Temporary tables to store JSON data
    DECLARE @InsertedTable TABLE (Data NVARCHAR(MAX));
    DECLARE @DeletedTable TABLE (Data NVARCHAR(MAX));

    -- Insert JSON data into temporary tables
    INSERT INTO @InsertedTable (Data)
    SELECT * FROM inserted FOR JSON PATH;

    INSERT INTO @DeletedTable (Data)
    SELECT * FROM deleted FOR JSON PATH;

    -- Handle INSERT operation
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @OperationType = 'INSERT';
        SET @NewValue = (SELECT Data FROM @InsertedTable);
        EXEC InsertLicenseAuditLog 'LicenseVendors', @OperationType, @OperationDate, @UserID, NULL, @NewValue;
    END

    -- Handle DELETE operation
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @OperationType = 'DELETE';
        SET @OldValue = (SELECT Data FROM @DeletedTable);
        EXEC InsertLicenseAuditLog 'LicenseVendors', @OperationType, @OperationDate, @UserID, @OldValue, NULL;
    END

    -- Handle UPDATE operation
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @OperationType = 'UPDATE';
        SET @OldValue = (SELECT Data FROM @DeletedTable);
        SET @NewValue = (SELECT Data FROM @InsertedTable);
        EXEC InsertLicenseAuditLog 'LicenseVendors', @OperationType, @OperationDate, @UserID, @OldValue, @NewValue;
    END
END;
GO

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

	SET @OperationDate = GETDATE()

     --Handle INSERT operation
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @OperationType = 'INSERT';
        SET @NewValue = (SELECT * FROM inserted FOR JSON PATH);
        EXEC InsertLicenseAuditLog 'LicenseVendors', @OperationType, @OperationDate, @UserID, NULL, @NewValue;
    END

     --Handle DELETE operation
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @OperationType = 'DELETE';
        SET @OldValue = (SELECT * FROM deleted FOR JSON PATH);
        EXEC InsertLicenseAuditLog 'LicenseVendors', @OperationType, @OperationDate, @UserID, @OldValue, NULL;
    END

     --Handle UPDATE operation
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @OperationType = 'UPDATE';
        SET @OldValue = (SELECT * FROM deleted FOR JSON PATH);
        SET @NewValue = (SELECT * FROM inserted FOR JSON PATH);
        EXEC InsertLicenseAuditLog 'LicenseVendors', @OperationType, @OperationDate, @UserID, @OldValue, @NewValue;
    END
END;
GO

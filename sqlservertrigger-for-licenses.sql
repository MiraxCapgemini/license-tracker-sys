-- Implementing triggers for Licenses Table in SQL Server
-- 1. Create table for Audit Table:
CREATE TABLE Auditing (
    AuditID INT PRIMARY KEY IDENTITY(1,1),
    TableName NVARCHAR(50),
    OperationType NVARCHAR(10),
    OperationDate DATETIME DEFAULT GETDATE(),
    UserID INT,
    OldValue NVARCHAR(MAX),
    NewValue NVARCHAR(MAX)
);

-- 2. Create trigger for INSERT operations:
CREATE TRIGGER trg_AuditLicensesInsert
ON Licenses
AFTER INSERT
AS
BEGIN
    DECLARE @UserID INT = 1; -- Replace with actual user ID logic
    INSERT INTO Auditing (TableName, OperationType, UserID, NewValue)
    SELECT 'Licenses', 'INSERT', @UserID, 
           CONCAT('LicenseID: ', inserted.LicenseID, ', LicenseName: ', inserted.LicenseName, ', LicenseType: ', inserted.LicenseType, ', PurchaseOrderID: ', inserted.PurchaseOrderID, ', ProductID: ', inserted.ProductID, ', IssueDate: ', inserted.IssueDate, ', ExpiryDate: ', inserted.ExpiryDate, ', Cost: ', inserted.Cost, ', Status: ', inserted.Status)
    FROM inserted;
END;

-- 3. Create trigger for UPDATE operations:
CREATE TRIGGER trg_AuditLicensesUpdate
ON Licenses
AFTER UPDATE
AS
BEGIN
    DECLARE @UserID INT = 1; -- Replace with actual user ID logic
    INSERT INTO Auditing (TableName, OperationType, UserID, OldValue, NewValue)
    SELECT 'Licenses', 'UPDATE', @UserID, 
           CONCAT('LicenseID: ', deleted.LicenseID, ', LicenseName: ', deleted.LicenseName, ', LicenseType: ', deleted.LicenseType, ', PurchaseOrderID: ', deleted.PurchaseOrderID, ', ProductID: ', deleted.ProductID, ', IssueDate: ', deleted.IssueDate, ', ExpiryDate: ', deleted.ExpiryDate, ', Cost: ', deleted.Cost, ', Status: ', deleted.Status),
           CONCAT('LicenseID: ', inserted.LicenseID, ', LicenseName: ', inserted.LicenseName, ', LicenseType: ', inserted.LicenseType, ', PurchaseOrderID: ', inserted.PurchaseOrderID, ', ProductID: ', inserted.ProductID, ', IssueDate: ', inserted.IssueDate, ', ExpiryDate: ', inserted.ExpiryDate, ', Cost: ', inserted.Cost, ', Status: ', inserted.Status)
    FROM inserted
    JOIN deleted ON inserted.LicenseID = deleted.LicenseID;
END;

-- 4. Create trigger for DELETE operations:
CREATE TRIGGER trg_AuditLicensesDelete
ON Licenses
AFTER DELETE
AS
BEGIN
    DECLARE @UserID INT = 1; -- Replace with actual user ID logic
    INSERT INTO Auditing (TableName, OperationType, UserID, OldValue)
    SELECT 'Licenses', 'DELETE', @UserID, 
           CONCAT('LicenseID: ', deleted.LicenseID, ', LicenseName: ', deleted.LicenseName, ', LicenseType: ', deleted.LicenseType, ', PurchaseOrderID: ', deleted.PurchaseOrderID, ', ProductID: ', deleted.ProductID, ', IssueDate: ', deleted.IssueDate, ', ExpiryDate: ', deleted.ExpiryDate, ', Cost: ', deleted.Cost, ', Status: ', deleted.Status)
    FROM deleted;
END;

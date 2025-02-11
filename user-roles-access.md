# Implementing User Roles into Power App

### 1. Define User Roles:
#### User Roles:
#### Admin - Read, Write & Approve Permissions
##### - {CanViewLicenses, CanSubmitLicenses, CanEditLicenses, CanApproveLicenses, CanViewReports}
#### Approver - Read & Approve Permissions
##### - {CanViewLicenses, CanApproveLicenses, CanViewReports}
#### GeneralUser - Read & Write Permissions
##### - {CanViewLicenses, CanSubmitLicenses, CanViewReports}
#### ReadOnly - Read Permissions
##### - {CanViewLicenses, CanViewReports}


### 2. Create User Roles Table (SQL):
```
  CREATE TABLE UserRoles (
      RoleID INT PRIMARY KEY IDENTITY(1,1),
      RoleName NVARCHAR(50),
      CanViewLicenses BIT,
      CanEditLicenses BIT,
      CanApproveLicenses BIT,
      CanViewReports BIT
  );
```


### 3. Assign Roles to Users Table (SQL):
```
  ALTER TABLE Users ADD RoleID INT;
```


### 4. Populate User Roles Table:
```
  INSERT INTO UserRoles (RoleName, CanViewLicenses, CanEditLicenses, CanApproveLicenses, CanViewReports)
  VALUES ('Admin', 1, 1, 1, 1),
         ('Approver', 1, 0, 1, 1),
         ('User', 1, 0, 0, 1);
```


### 5. Fetch User Role in Power App:
```
  // OnStart property of the app
  Set(CurrentUser, User());
  Set(CurrentUserRole, LookUp(Users, Email = CurrentUser.Email).RoleID);
  Set(UserPermissions, LookUp(UserRoles, RoleID = CurrentUserRole));
```


### 6. Control Access Based on Role (Power App):
```
  // Visible property of the License Management button
  UserPermissions.CanViewLicenses

  // Visible property of the Add/Edit License form
  UserPermissions.CanEditLicenses

  // Visible property of the Approvals button
  UserPermissions.CanApproveLicenses

  // Visible property of the Approve/Reject buttons
  UserPermissions.CanApproveLicenses

  // Visible property of the Submit button/form
  UserPermissions.CanSubmitLicenses

  // Visible property of the License Reports button
  UserPermissions.CanViewReports
```




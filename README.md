# Movie/Event Ticket Management Database

This project provides a SQL Server-based database for managing movie ticket sales, showtimes, seats, orders, and reporting. It includes full data model, stored procedures, views, indexing, and role-based security.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Folder Structure](#folder-structure)
3. [Installation & Setup](#installation--setup)
4. [Project Objects](#project-objects)
5. [Test Scripts](#test-scripts)
6. [Security & Roles](#security--roles)
7. [Server Requirements](#server-requirements)
8. [Conventions](#conventions)
9. [Team Member](#team-member)

## Prerequisites

* Microsoft SQL Server 2016 or later (for `HASHBYTES('SHA2_256')`)
* SQL Server Management Studio (SSMS) or equivalent
* .NET / Application layer to call these procedures (optional)

## Folder Structure

```
├── 01_Schemas/
│   ├── 01_CinemaTable.sql
│   ├── 02_SeatTable.sql
│   ├── 03_MovieTable.sql
│   ├── 04_ShowtimeTable.sql
│   ├── 05_CustomerTable.sql
│   ├── 06_EmployeeTable.sql
│   ├── 07_OrderTable.sql
│   └── 08_OrderDetailTable.sql
│
├── 02_Indexes/
│   └── idx_CreateIndexes.sql
│
├── 03_Views/
│   ├── vw_AvailableShowtimes.sql
│   ├── vw_CinemaSeatStatus.sql
│   ├── vw_DailyRevenue.sql
│   └── vw_MonthlyRevenue.sql
│
├── 04_StoredProcedures/
│   ├── sp_AddMovie.sql
│   ├── sp_UpdateMovie.sql
│   ├── sp_DeleteMovie.sql
│   ├── sp_AddShowtime.sql
│   ├── sp_UpdateShowtime.sql
│   ├── sp_DeleteShowtime.sql
│   ├── sp_GetAvailableSeats.sql
│   ├── sp_CreateOrder.sql
│   ├── sp_PayOrder.sql
│   ├── sp_CancelOrder.sql
│   ├── sp_GetMovieSchedule.sql
│   ├── sp_GetRevenueByDate.sql
│   ├── sp_GetRevenueByMonth.sql
│   ├── sp_GetTopMovies.sql
│   ├── sp_GetTopCinemas.sql
│   ├── sp_AddCustomer.sql
│   ├── sp_Login.sql
│   ├── sp_AddEmployee.sql
│   ├── sp_UpdateEmployee.sql
│   └── sp_DeleteEmployee.sql
│
├── 05_Roles_Permissions/
│   ├── 00_CreateLogins.sql
│   ├── 01_CreateUsers.sql
│   ├── 02_CreateDBRoles.sql
│   ├── 03_GrantPermissions.sql
│   │    ├── GrantPermissions_Customer.sql
│   │    ├── GrantPermissions_Employee.sql
│   │    └── GrantPermissions_Admin.sql
│   └── 04_RevokePermissions.sql
│        ├── RevokePermissions_Customer.sql
│        ├── RevokePermissions_Employee.sql
│        └── RevokePermissions_Admin.sql
│
├── 06_TestScripts/                  
│   ├── TestScript1_CreateShema.sql
│   ├── TestScript2_Customer.sql
│   ├── TestScript3_Employe.sql
│   ├── TestScript4_Admin.sql
│   └── TestScript5_RolePermission.sql
│
└── README.md                          

```

## Installation & Setup

1. **Create Database**

   ```sql
   CREATE DATABASE MovieTheaterManagement;
   GO
   USE MovieTheaterManagement;
   ```
2. **Run Schema Scripts & Create Seed Sample Data**

   * `/05_TestScript/TestScript1_CreateShema.sql` OR Import all scripts under `/01_Schemas/`
   * `/02_Indexes/idx_CreateIndexes.sql`
3. **Create Stored Procedures & Views**

   * Import all scripts under `/04_StoredProcedures`
   * Import all scripts under `/03_Views`
4. **Configure Security**

   * `/05_Roles_Permissions/00_CreateLogins/CreateLogins.sql` (run in master)
   * `/05_Roles_Permissions/01_CreateDBRoles/CreateDBRoles.sql`
   * `/05_Roles_Permissions/02_GrantPermissions/...` for Customer/Employee/Admin
5. **Test Functionality**

   * Run test scripts in `/06_TestScripts/` in order:

     1. `TestScript2_Customer.sql`
     2. `TestScript3_Employe.sql`
     3. `TestScript4_Admin.sql`
     4. `TestScript5_RolePermission.sql`

## Project Objects

* **Tables**: Movie, Cinema, Seat, Showtime, Customer, Employee, \[Order], OrderDetail
* **Indexes**: Covering indexes on status, dates, foreign keys
* **Stored Procedures**:

  * Customer: `sp_AddCustomer`, `sp_Login`, etc.
  * Movie/Showtime management: `sp_AddMovie`, `sp_AddShowtime`, etc.
  * Order flow: `sp_CreateOrder`, `sp_PayOrder`, `sp_CancelOrder`
  * Reporting: `sp_GetRevenueByDate`, `sp_GetRevenueByMonth`, `sp_GetTopMovies`, `sp_GetTopCinemas`
* **Views**: `vw_AvailableShowtimes`, `vw_CinemaSeatStatus`, `vw_DailyRevenue`, `vw_MonthlyRevenue`

## Test Scripts

See `/05_TestScripts/` for detailed workflow tests:

* Part1: Schema & Seed
* Part2: Customer operations
* Part3: Employee operations
* Part4: Admin operations
* Part5: Role-based security demo

## Security & Roles

* **Roles**: `db_Customer`, `db_Employee`, `db_Admin`
* **Logins**: `testcust_login`, `testemp_login`, `testadmin_login`
* **Users**: `testcust_user`, `testemp_user`, `testadmin_user`
* Permissions granted/revoked under `/04_Roles_Permissions`

## Server Requirements

* SQL Server 2016+ (for SHA2\_256)
* Sufficient disk space for log data
* Collation: `SQL_Latin1_General_CP1_CI_AS` (or adjust as needed)

## Conventions

* Schema: `dbo.`
* Naming: `sp_` prefix for procedures, `vw_` for views, `idx_` for indexes
* Transaction handling in SP: TRY/CATCH with XACT\_ABORT
* Soft deletes: Movie uses status flag
* Seat uniqueness: `UNIQUE(showtime_id, seat_id)` in OrderDetail

## Team Member
* Trong Le Minh (Team Leader)
* Vinh Nguyen Sy
---



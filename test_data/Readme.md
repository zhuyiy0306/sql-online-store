INFO 330 | PROJECT 1 | TEAM 11 CB
LIVE DATABASE TESTING README + RESULTS
Updated: November 15, 2026 (revised after instructor announcement)
============================================================

IMPORTANT INSTRUCTOR UPDATE
---------------------------
Professor announced that creating a VIEW, stored PROCEDURE, or FUNCTION
is NO LONGER REQUIRED for this project. Earlier guidance to add a
monthly-profit view is obsolete. There is no need to make that schema
change. Amy has said she already created a monthly revenue query; verify
its result and cancellation policy with her, but it does not need to be
implemented as a view.

PURPOSE
-------
This package checks the online store database already implemented on the
class SQL server. It contains READ-ONLY tests (no INSERT, UPDATE, DELETE,
CREATE, or DROP commands). These are independently prepared verification
queries, not substitutes for the team's original deliverable SQL.

LIVE CONNECTION VERIFIED BY TEAM MEMBER
---------------------------------------
Server:   uwinfo330kf.database.windows.net (SQL Server identifies as uwinfo330kf)
Database: projects
Schema:   Team11CB
Table count: 10 of 10 FOUND

All test outputs below are results the team member reported after running
SQL in VS Code against projects.Team11CB on November 15, 2026.
They were not executed independently by the README author. Database contents
may change if teammates continue working.

HOW TO OPEN AND RUN IN VS CODE
-----------------------------
1. Unzip the folder. Choose File > Open Folder in VS Code, or press
   Command+O on Mac to open an individual .sql file.
2. In the SQL editor, choose the "INFO 330 Team Database" connection.
3. Confirm CurrentDatabase is projects, not samples.
4. Click Execute Query (SQL Server extension); look through EACH result grid.
5. Suggested order (the first five have already been run successfully):
   00_Connection_And_Schema.sql      Database, 10 tables, data types
   01_Live_Data_Overview.sql        Data counts and order statuses
   02_Data_Integrity.sql            Foreign-key/data-quality checks
   03_Eight_Use_Case_Tests.sql      Demonstrations of 8 project use cases
   04_Grading_Requirements.sql      PKs, FKs, indexes, DB objects
   05_Exact_Key_Relationships.sql  OPTIONAL: exact PK/FK column mappings
6. All six SQL files are read-only. Saving or uploading a .sql file does NOT
   change the database. Running read-only SELECT queries does not either.
7. Do NOT rerun the old data-import/INSERT or table-creation scripts to
   "populate" the database: existing rows may be duplicated or conflict.
   In particular, the team's UseCase5-Placeorder.sql inserts/commits an order.
   Coordinate with the team before any write or schema change.

TEST 00 | CONNECTION AND SCHEMA | COMPLETED
------------------------------------------
Result: all 10 Team11CB tables returned FOUND:
Customers, Addresses, Categories, Products, Orders, OrderDetails,
Shipments, Wishlists, WishlistItems, Payments.

Test 00 also returned live column definitions. Confirmed examples:
  Addresses.CustomerID    int
  Addresses.AddressLabel  varchar(50)
  Addresses.ZIPCode       varchar(15) (nullable)
  Orders.OrderID          bigint (not IDENTITY)
  OrderDetails.OrderID    bigint
  Products.ProductID      int IDENTITY
  Products.Availability   int (nullable), NOT bit
  Payments.PaymentID      int IDENTITY
  Customers.CustomerID    int IDENTITY

IMPORTANT: The earlier "create_all_tables.sql" is an older draft. Its
unqualified tables and some definitions (e.g. OrderID INT IDENTITY and
Availability BIT) differ from the live Team11CB schema. Use the LIVE schema
for final SQL, ER diagram, and written report.

TEST 01 | LIVE DATA OVERVIEW | COMPLETED
---------------------------------------
Record counts (as of test run):
  Customers       34        Addresses       34
  Categories       5        Products        20
  Orders          21        OrderDetails   401
  Shipments       19        Wishlists       34
  WishlistItems   14        Payments        20

Order status distribution (21 orders total):
  Delivered 12 | Shipped 4 | Pending 2 | Processing 2 | Cancelled 1
Shipment statuses: Delivered 12 | In Transit 4 | Not Shipped 3
Payment statuses: Paid 18 | Pending 1 | Refunded 1
Earliest order date: 2026-10-01 11:15:00
Latest order date:   2026-11-15 09:23:28.780

Interpretation: data exists in every table. The existence of data alone does
not prove each business rule is correct or that the final report matches it.
Potential sample-data questions:
* Many historic orders have 20 distinct products and high unit quantities.
  This may simply reflect how the demonstration records were generated.
* OrderID 20261020002 was saved with OrderDate 2026-11-15, even though
  the number resembles an October 20 date. Ask whether that is intentional.
* There are 21 orders and 20 payment rows; verify whether an unpaid,
  cancelled, or newly created order explains the difference.

TEST 02 | DATA INTEGRITY | COMPLETED WITH FOLLOW-UP
--------------------------------------------------
12/12 missing-reference checks returned IssueCount = 0:
  Addresses missing customer; Products unknown category; Orders missing
  customer/billing address/shipping address; OrderDetails missing order/
  product; Wishlists missing customer; WishlistItems missing wishlist/
  product; Shipments missing order; Payments missing order.

5/5 basic business-rule checks returned IssueCount = 0:
  Orders without line items; nonpositive line-item quantities; negative
  purchase prices; NULL purchase costs; negative current product prices.

Shipment-date consistency test returned NO ROWS: no matched shipment
status with missing ShippedDate under that test's conditions.

PAYMENT RECONCILIATION NEEDS REVIEW. For PAID records, line-item sums and
payment sums differed by large amounts (sample rows shown below).
  Order ID      Line item total   Paid total    Paid minus items
  20261001001       $4,467.00       $49.99        -$4,417.01
  20261002001       $3,717.00       $89.00        -$3,628.00
  20261003001       $4,070.00      $129.50        -$3,940.50
  20261004001       $4,934.00       $35.00        -$4,899.00
  20261005001       $3,403.00       $78.90        -$3,324.10

These are discrepancies, not automatically schema errors. The team must
confirm whether test payments were generated independently, represent
partial payments, or follow some other explicit rule. Do not silently edit
records or claim payment totals reconcile. This check compares line totals
against paid amounts, not tax/shipping/refunds or amounts due.

TEST 03 | EIGHT USE CASES | READ-ONLY QUERIES EXECUTED
------------------------------------------------------
1) Customer wishlist and pending orders:
   Customer 10001 had 3 wishlist items (Black Knit Sweater, Wide Leg
   Pants, Mini Shoulder Bag) and 2 Pending/Processing orders.
   RESULT: working read-only demonstration.

2) Ten bestselling products for October 2026:
   Returned 10 products. Pleated Mini Skirt was first with 115 units;
   Floral Summer Dress second with 113 units.
   RESULT: working read-only demonstration.
   POLICY DECISION: This bestseller query includes cancelled orders,
   whereas the profit query below excludes cancelled orders. Decide
   whether both should exclude cancellations for consistency.

3) Profit for a month/year:
   October 2026 query returned 380 order-detail rows, revenue $80,820.00,
   cost $35,619.00, and gross profit $45,201.00.
   RESULT: MONTHLY query executed. A separate YEARLY calculation exists in
   teammate INFO330_UseCases_3_7_8.sql and should ALSO be run/verified.
   Profit uses historical purchase price and historical purchase cost,
   and excludes cancelled orders; these are order-based figures rather
   than reconciled cash payments.

4) Search products by name/category:
   A Tops + Sweater search returned ProductID 102 "Black Knit Sweater",
   CurrentPrice 45.00, Availability 10.
   RESULT: working. Availability is an INT in the live database, so do
   not describe it as a 0/1 BIT unless the actual business rule says so.

5) Place order using saved addresses:
   Read-only query returned customer address labels and existing orders
   linked to a saved "Home" address (e.g. customer 10001).
   RESULT: PARTIAL ONLY. It proves retrieval/linkage, not that an order
   can actually be created. UseCase5-Placeorder.sql performs INSERT/
   COMMIT and needs group-approved write testing (prefer a safe transaction
   rollback where feasible), or evidence from a successfully created order.

6) Review historical orders:
   Order 20261001001 returned product names, quantities, purchase prices,
   and line subtotals.
   RESULT: working. Verify report screenshots show subtotal values.

7) Received but not yet shipped:
   Returned 4 orders with Pending/Processing status (Oct 17, Oct 18,
   Oct 19 and Nov 15), consistent with the rule excluding dispatched
   shipments.
   RESULT: working under the team's definition of "not shipped".

8) Review shipment/delivery status:
   Order 20261001001 returned UPS, tracking TEST-202610-1, and a
   Delivered shipment record.
   RESULT: working.

TEST 04 | KEYS, INDEXES AND OPTIONAL OBJECT CHECK | EXECUTED
--------------------------------------------------------
* Every one of the 10 tables has a primary-key constraint (10 PKs).
* There are 12 foreign-key constraints. All reported IsDisabled = 0
  and IsNotTrusted = 0 (enabled and trusted).
* There are 11 indexes listed: 10 clustered PK indexes plus a unique,
  nonclustered index on Customers (corresponding to a UNIQUE constraint;
  exact indexed column should be checked before citing it).
* No VIEW, stored PROCEDURE, or FUNCTION appeared under Team11CB in
  the reported metadata output. THIS IS NOT A PROBLEM OR MISSING GRADE
  REQUIREMENT. The professor subsequently announced that the requirement
  to create a stored procedure, view, or function had been REMOVED from
  Project 1, because these topics have not yet been covered in lecture.
  The assignment was updated accordingly. Do NOT create a new view or
  stored procedure simply to satisfy the obsolete requirement.

AMY'S MONTHLY REVENUE QUERY
---------------------------
Amy reported that she has already created a similar monthly REVENUE query.
Coordinate with her before writing or uploading another one. The group
also has gross PROFIT SQL in INFO330_UseCases_3_7_8.sql. Revenue and
profit are DIFFERENT metrics (profit deducts the historical item costs).
Test 03's October query reported revenue of $80,820 and gross profit of
$45,201. Compare Amy's monthly revenue output to the group's agreed
method and check whether it includes cancelled orders before claiming it
matches. The README author has NOT seen or executed Amy's new query.


ER DIAGRAM COMPARISON | MOSTLY CONSISTENT, NOT FULLY CERTIFIED
--------------------------------------------------------------
The ER diagram in the project proposal shows ten entities, and all ten
are implemented. Confirmed links include:
  Customers -> Addresses                  (FK)
  Customers -> Orders                     (FK)
  Customers -> Wishlists                  (FK)
  Categories -> Products                  (FK)
  Orders -> OrderDetails -> Products       (two FKs)
  Orders -> Shipments                     (FK)
  Orders -> Payments                      (FK)
  Wishlists -> WishlistItems -> Products  (two FKs)
  Orders -> Addresses (billing + shipping; two FKs)

The *diagram* uses Orders.OrderID bigint, Products.Availability int,
Addresses primary key (CustomerID, AddressLabel), Products.CategoryName
as an FK, and OrderDetails (OrderID, ProductID) as a composite PK.
Observed live types/relationships are consistent with many of these.
However Test 04 only printed FK NAMES and table pairs, NOT the complete
FK column mappings. It is premature to say the diagram is a perfect match.

RUN NEW OPTIONAL TEST 05 to get the exact PK/unique columns and FK
child-to-parent column pairs. Compare them one by one to the diagram,
including the composite billing/shipping-address relationships. If
anything differs, update the FINAL ER diagram and report to reflect
what is actually on the server. Also review any changed nullable flags,
lengths, and primary-key/identity choices from the old draft.

INDEX / REPORT NOTE
-------------------
The current index list primarily contains PK indexes plus a UNIQUE index.
Your written report must discuss common access patterns (such as searching
products by name or category), which indexes were chosen, and why. If no
additional search indexes were created, either justify that decision for
small test data or coordinate improvements with the group. Do not claim
that search-specific indexes exist unless Test 04 shows them.

INDIVIDUAL COMPONENT | SEPARATE FROM THE EIGHT GROUP USE CASES
--------------------------------------------------------------
Assignment says: prepare FIVE SQL-answerable questions for ANOTHER group
member, and submit those five questions PLUS SQL answers to questions
someone gave YOU, naming the member who supplied them. The 8 proposal
use cases are group deliverables, NOT automatically the 5 individual
questions. Confirm who you are exchanging questions with.

Suggested five individual questions (for a teammate):
  1. Which customers have placed the most orders?
  2. What is the average order value for customers with orders?
  3. Which products have never been ordered?
  4. How many orders are in each order status?
  5. Which customers have saved more than one address?
Some legitimate queries may return zero rows in the sample data. Do NOT
submit invented results or claim to have answered questions you have not
received yet.

REMAINING ACTIONS BEFORE SUBMISSION
-----------------------------------
[ ] Share payment-total discrepancies and confirm whether intentional.
[ ] Agree whether cancelled orders should count in bestselling totals.
[ ] Run and verify YEARLY gross profit query, not only October monthly.
[ ] Verify actual order-placement workflow for Use Case 5; get approval
    before INSERT/COMMIT and avoid duplicate records.
[x] Professor removed view/procedure/function requirement: no action needed.
[ ] Confirm Amy's monthly revenue query is present and uses the intended
    order-date window and cancellation policy; avoid duplicate work.
[ ] Run Test 05 and finish exact FK/PK-column-vs-ERD comparison.
[ ] Complete report sections: use cases, access patterns, indexes,
    field definitions, normalization/design rationale, final ER diagram.
[ ] Prepare presentation: topic, two entities and business rule, tricky
    data types, one stakeholder query per student, lessons/challenges.
[ ] Individually: exchange five questions and submit SQL answers to the
    questions received, with the question-giver's name.
[ ] Have teammates verify any newly added database objects/updated data.

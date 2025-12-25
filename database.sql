--- Down Script
---Drop DB
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'event_rental_db') 
CREATE DATABASE event_rental_db

---Drop Constraints
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_rentals_customer_id')
    ALTER TABLE rentals DROP CONSTRAINT fk_rentals_customer_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_rental_detail_rental_id')
    ALTER TABLE rental_detail DROP CONSTRAINT fk_rental_detail_rental_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_rental_detail_equipment_id')
    ALTER TABLE rental_detail DROP CONSTRAINT fk_rental_detail_equipment_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_technician_specialization_technician_id')
    ALTER TABLE technician_specialization DROP CONSTRAINT fk_technician_specialization_technician_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_technician_specialization_specialization_id')
    ALTER TABLE technician_specialization DROP CONSTRAINT fk_technician_specialization_specialization_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_deliveries_rental_id')
    ALTER TABLE deliveries DROP CONSTRAINT fk_deliveries_rental_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_deliveries_vehicle_id')
    ALTER TABLE deliveries DROP CONSTRAINT fk_deliveries_vehicle_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_delivery_driver_delivery_id')
    ALTER TABLE delivery_driver DROP CONSTRAINT fk_delivery_driver_delivery_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_delivery_driver_driver_id')
    ALTER TABLE delivery_driver DROP CONSTRAINT fk_delivery_driver_driver_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_invoices_rental_id')
    ALTER TABLE invoices DROP CONSTRAINT fk_invoices_rental_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_payments_invoice_id')
    ALTER TABLE payments DROP CONSTRAINT fk_payments_invoice_id

---Drop Tables
DROP TABLE IF EXISTS payments
DROP TABLE IF EXISTS invoices
DROP TABLE IF EXISTS delivery_driver
DROP TABLE IF EXISTS deliveries
DROP TABLE IF EXISTS vehicles
DROP TABLE IF EXISTS drivers
DROP TABLE IF EXISTS technician_specialization
DROP TABLE IF EXISTS specializations
DROP TABLE IF EXISTS technicians
DROP TABLE IF EXISTS rental_detail
DROP TABLE IF EXISTS rentals
DROP TABLE IF EXISTS equipment
DROP TABLE IF EXISTS customers

---Drop Trigger
IF OBJECT_ID('dbo.trg_payments_update_invoice_status', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_payments_update_invoice_status;

---Drop Procedure
IF OBJECT_ID('dbo.p_create_rental', 'P') IS NOT NULL
    DROP PROCEDURE dbo.p_create_rental;

---Drop Function
IF OBJECT_ID('dbo.f_equipment_by_category', 'IF') IS NOT NULL
    DROP FUNCTION dbo.f_equipment_by_category;

GO

---Up Script
USE event_rental_db
GO

---Customers
CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) NOT NULL,
    customer_first_name VARCHAR(50) NOT NULL,
    customer_last_name VARCHAR(50) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    customer_email VARCHAR(100) NOT NULL,
    customer_street VARCHAR(100) NOT NULL,
    customer_city VARCHAR(50) NOT NULL,
    customer_state CHAR(2) NOT NULL,
    customer_zip VARCHAR(10) NOT NULL,
    CONSTRAINT pk_customers_customer_id PRIMARY KEY(customer_id),
    CONSTRAINT u_customers_customer_email UNIQUE(customer_email),
    CONSTRAINT ck_customers_phone_not_empty CHECK(len(customer_phone)>0),
    CONSTRAINT ck_customers_zip_not_empty CHECK(len(customer_zip)>0)
)

---Equipment
CREATE TABLE equipment (
    equipment_id INT IDENTITY(1,1) NOT NULL,
    equipment_name VARCHAR(100) NOT NULL,
    equipment_category VARCHAR(50) NOT NULL,
    daily_rate DECIMAL(10,2) NOT NULL,
    availability_status VARCHAR(20) NOT NULL,
    condition VARCHAR(20) NOT NULL,
    CONSTRAINT pk_equipment_equipment_id PRIMARY KEY(equipment_id),
    CONSTRAINT ck_equipment_daily_rate_positive CHECK(daily_rate>0)
)

---Rentals
CREATE TABLE rentals (
    rental_id INT IDENTITY(1,1) NOT NULL,
    customer_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    rental_status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_rentals_rental_id PRIMARY KEY(rental_id),
    CONSTRAINT ck_rentals_valid_dates CHECK(start_date<=end_date),
    CONSTRAINT ck_rentals_total_amount_nonnegative CHECK(total_amount>=0)
)

---Rental Detail
CREATE TABLE rental_detail (
    rental_id INT NOT NULL,
    equipment_id INT NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_rental_detail PRIMARY KEY(rental_id, equipment_id),
    CONSTRAINT ck_rental_detail_quantity_positive CHECK(quantity > 0),
    CONSTRAINT ck_rental_detail_subtotal_nonnegative CHECK(subtotal >= 0)
)

---Technicians
CREATE TABLE technicians (
    technician_id INT IDENTITY(1,1) NOT NULL,
    technician_first_name VARCHAR(50) NOT NULL,
    technician_last_name VARCHAR(50) NOT NULL,
    technician_phone VARCHAR(20) NOT NULL,
    CONSTRAINT pk_technicians_technician_id PRIMARY KEY(technician_id)
)

---Specializations
CREATE TABLE specializations (
    specialization_id INT IDENTITY(1,1) NOT NULL,
    specialization_name VARCHAR(50) NOT NULL,
    CONSTRAINT pk_specializations_specialization_id PRIMARY KEY (specialization_id),
    CONSTRAINT u_specializations_specialization_name UNIQUE (specialization_name)
)

---Technician_Specialization 
CREATE TABLE technician_specialization (
    technician_id INT NOT NULL,
    specialization_id INT NOT NULL,
    CONSTRAINT pk_technician_specialization PRIMARY KEY(technician_id, specialization_id)
)

---Drivers
CREATE TABLE drivers (
    driver_id INT IDENTITY(1,1) NOT NULL,
    driver_first_name VARCHAR(50) NOT NULL,
    driver_last_name VARCHAR(50) NOT NULL,
    driver_phone VARCHAR(20) NOT NULL,
    license_no VARCHAR(50) NOT NULL,
    CONSTRAINT pk_drivers_driver_id PRIMARY KEY (driver_id),
    CONSTRAINT u_drivers_license_no UNIQUE (license_no)
)

---Vehicles
CREATE TABLE vehicles (
    vehicle_id INT IDENTITY(1,1) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    plate_number VARCHAR(20) NOT NULL,
    capacity VARCHAR(50) NOT NULL,
    CONSTRAINT pk_vehicles_vehicle_id PRIMARY KEY(vehicle_id),
    CONSTRAINT u_vehicles_plate_number UNIQUE(plate_number)
)

---Deliveries
CREATE TABLE deliveries (
    delivery_id INT IDENTITY(1,1) NOT NULL,
    rental_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    delivery_status VARCHAR(20) NOT NULL,
    delivery_date DATETIME NOT NULL,
    CONSTRAINT pk_deliveries_delivery_id PRIMARY KEY(delivery_id)
)

---Delivery_Driver
CREATE TABLE delivery_driver (
    delivery_id INT NOT NULL,
    driver_id INT NOT NULL,
    CONSTRAINT pk_delivery_driver PRIMARY KEY(delivery_id, driver_id)
)

---Invoices
CREATE TABLE invoices (
    invoice_id INT IDENTITY(1,1) NOT NULL,
    rental_id INT NOT NULL,
    issue_date DATE NOT NULL,
    payment_status VARCHAR(20) NOT NULL, 
    total_amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_invoices_invoice_id PRIMARY KEY (invoice_id),
    CONSTRAINT u_invoices_rental_id UNIQUE (rental_id),
    CONSTRAINT ck_invoices_total_amount_nonnegative CHECK (total_amount>=0)
)

---Payments
CREATE TABLE payments (
    payment_id INT IDENTITY(1,1) NOT NULL,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(20) NOT NULL, 
    amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_payments_payment_id PRIMARY KEY (payment_id),
    CONSTRAINT ck_payments_amount_positive CHECK (amount>0)
)
GO

---Foreign Key constraints 

---rentals - customers
ALTER TABLE rentals ADD CONSTRAINT fk_rentals_customer_id
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)

---rental_detail - rentals
ALTER TABLE rental_detail ADD CONSTRAINT fk_rental_detail_rental_id
    FOREIGN KEY (rental_id) REFERENCES rentals (rental_id)

---rental_detail - equipment
ALTER TABLE rental_detail ADD CONSTRAINT fk_rental_detail_equipment_id
    FOREIGN KEY (equipment_id) REFERENCES equipment (equipment_id)

---technician_specialization - technicians
ALTER TABLE technician_specialization ADD CONSTRAINT fk_technician_specialization_technician_id
    FOREIGN KEY (technician_id) REFERENCES technicians (technician_id)

---technician_specialization - specializations
ALTER TABLE technician_specialization ADD CONSTRAINT fk_technician_specialization_specialization_id
    FOREIGN KEY (specialization_id) REFERENCES specializations (specialization_id)

---deliveries - rentals
ALTER TABLE deliveries ADD CONSTRAINT fk_deliveries_rental_id
    FOREIGN KEY (rental_id) REFERENCES rentals (rental_id)

---deliveries - vehicles
ALTER TABLE deliveries ADD CONSTRAINT fk_deliveries_vehicle_id
    FOREIGN KEY (vehicle_id) REFERENCES vehicles (vehicle_id)

---delivery_driver - deliveries
ALTER TABLE delivery_driver ADD CONSTRAINT fk_delivery_driver_delivery_id
    FOREIGN KEY (delivery_id) REFERENCES deliveries (delivery_id)

---delivery_driver - drivers
ALTER TABLE delivery_driver ADD CONSTRAINT fk_delivery_driver_driver_id
    FOREIGN KEY (driver_id) REFERENCES drivers (driver_id)

---invoices - rentals
ALTER TABLE invoices ADD CONSTRAINT fk_invoices_rental_id
    FOREIGN KEY (rental_id) REFERENCES rentals (rental_id)

---payments - invoices
ALTER TABLE payments ADD CONSTRAINT fk_payments_invoice_id
    FOREIGN KEY (invoice_id) REFERENCES invoices (invoice_id)
GO


---Sample Data Imputation
INSERT INTO customers (customer_first_name, customer_last_name, customer_phone, customer_email, customer_street, customer_city, 
    customer_state, customer_zip)
VALUES ('Alice', 'Johnson', '555-1111', 'alice.johnson@example.com', '123 Maple St', 'Syracuse', 'NY', '13210'),
('Bob','Smith','555-2222', 'bob.smith@example.com', '456 Oak Ave', 'Syracuse', 'NY', '13220')

INSERT INTO equipment (equipment_name, equipment_category, daily_rate, availability_status, condition)
VALUES('JBL Speaker Set', 'Audio', 100.00, 'Available', 'Good'),
('LED Lighting Rig', 'Lighting', 150.00, 'Available', 'New'),
('20x20 Event Tent', 'Tent', 200.00, 'Available', 'Good')

INSERT INTO technicians (technician_first_name, technician_last_name, technician_phone)
VALUES('Carlos', 'Martinez', '555-3333')

INSERT INTO specializations (specialization_name)
VALUES('Audio'), ('Lighting')

INSERT INTO technician_specialization (technician_id, specialization_id)
VALUES(1, 1), (1, 2)

INSERT INTO drivers (driver_first_name, driver_last_name, driver_phone, license_no)
VALUES('Derek', 'Taylor', '555-4444', 'LIC12345'),
('Emma', 'Brown', '555-5555', 'LIC67890')

INSERT INTO vehicles (vehicle_type, plate_number, capacity)
VALUES('Truck', 'ABC-1234', '2T')

INSERT INTO rentals (customer_id, start_date, end_date, rental_status, total_amount)
VALUES(1, '2025-01-01', '2025-01-03', 'Confirmed', 600.00)

INSERT INTO rental_detail (rental_id, equipment_id, quantity, subtotal)
VALUES(1, 1, 2, 600.00)

INSERT INTO deliveries (rental_id, vehicle_id, delivery_status, delivery_date)
VALUES(1, 1, 'Scheduled', '2025-01-01T10:00:00')

INSERT INTO delivery_driver (delivery_id, driver_id)
VALUES(1, 1), (1, 2)

INSERT INTO invoices (rental_id, issue_date, payment_status, total_amount)
VALUES(1, '2025-01-01', 'Paid', 600.00)

INSERT INTO payments (invoice_id, payment_date, payment_method, amount)
VALUES(1, '2025-01-01', 'Card', 600.00)
GO

---Verify
SELECT * FROM customers
SELECT * FROM equipment
SELECT * FROM rentals
SELECT * FROM rental_detail
SELECT * FROM technicians
SELECT * FROM specializations
SELECT * FROM technician_specialization
SELECT * FROM drivers
SELECT * FROM vehicles
SELECT * FROM deliveries
SELECT * FROM delivery_driver
SELECT * FROM invoices
SELECT * FROM payments
GO

---Function
CREATE FUNCTION dbo.f_equipment_by_category (@category VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT e.equipment_id, e.equipment_name, e.equipment_category, e.daily_rate, e.availability_status, e.[condition]
    FROM equipment e
    WHERE e.equipment_category = @category
);
GO

---Procedure
CREATE PROCEDURE dbo.p_create_rental
(@customer_id INT, @start_date DATE, @end_date DATE, @equipment_id INT, @quantity INT)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @days INT;
    DECLARE @daily_rate DECIMAL(10,2);
    DECLARE @subtotal DECIMAL(10,2);
    DECLARE @new_rental_id INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @quantity<=0
        BEGIN
            RAISERROR('Quantity must be greater than 0.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @start_date>@end_date
        BEGIN
            RAISERROR('Start date cannot be after end date.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        SET @days = DATEDIFF(DAY, @start_date, @end_date) + 1;
        SELECT @daily_rate = daily_rate
        FROM equipment
        WHERE equipment_id = @equipment_id;

        IF @daily_rate IS NULL
        BEGIN
            RAISERROR('Invalid equipment_id.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @subtotal = @daily_rate * @quantity * @days;
        INSERT INTO rentals (customer_id, start_date, end_date, rental_status, total_amount)
        VALUES (@customer_id, @start_date, @end_date, 'Confirmed', @subtotal);

        SET @new_rental_id = SCOPE_IDENTITY();
        INSERT INTO rental_detail (rental_id, equipment_id, quantity, subtotal)
        VALUES (@new_rental_id, @equipment_id, @quantity, @subtotal);
        COMMIT TRANSACTION;

        SELECT @new_rental_id AS new_rental_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END
GO


---Creating Trigger
CREATE TRIGGER dbo.trg_payments_update_invoice_status
ON dbo.payments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH ChangedInvoices AS (
        SELECT DISTINCT invoice_id FROM inserted
        UNION
        SELECT DISTINCT invoice_id FROM deleted
    ),
    InvoiceTotals AS (
        SELECT i.invoice_id, i.total_amount, COALESCE(SUM(p.amount), 0) AS total_paid
        FROM invoices i
        LEFT JOIN payments p ON i.invoice_id = p.invoice_id
        WHERE i.invoice_id IN (SELECT invoice_id FROM ChangedInvoices)
        GROUP BY i.invoice_id, i.total_amount
    )
    UPDATE i
    SET payment_status = CASE 
        WHEN it.total_paid <= 0 THEN 'Unpaid'
        WHEN it.total_paid < it.total_amount THEN 'Partially_Paid'
        ELSE 'Paid'
    END
    FROM invoices i
    JOIN InvoiceTotals it
        ON i.invoice_id = it.invoice_id;
END
GO

# Event Equipment Rental System

## Overview
The Event Equipment Rental System is a relational database designed to support the operational needs of an event equipment rental business.  
The database enables structured management of equipment inventory, customers, vendors, and rental transactions while enforcing data integrity and consistency through relational constraints.

This project focuses on translating business requirements into a normalized relational schema and implementing it using SQL best practices.

---

## Business Context
Event rental companies must track large inventories of equipment across multiple rentals, customers, and time periods.  
This database is designed to support key operational workflows such as:

- Tracking available and rented equipment
- Managing customer rental history
- Associating vendors with supplied equipment
- Enforcing valid rental transactions
- Preventing data inconsistencies across the system

---

## Core System Capabilities
- Centralized equipment inventory management
- Customer and vendor data tracking
- Rental booking and scheduling support
- Enforcement of business rules through constraints
- Structured relationships between all core entities

---

## Repository Contents
- **database.sql**  
  SQL script containing table creation, primary keys, foreign keys, constraints, and sample data used for validation.

- **conceptual_model.pdf**  
  Conceptual ER diagram representing high-level entities and their relationships.

- **logical_model.pdf**  
  Logical database schema defining tables, attributes, primary keys, and foreign key relationships.

---

## Database Design Approach

### Conceptual Design
- Identified core business entities such as equipment, customers, vendors, rentals, and rental details
- Defined relationships and cardinalities based on real-world business rules
- Modeled the system using a conceptual ER diagram to represent data flow and dependencies

### Logical Design
- Converted the conceptual model into a relational schema
- Applied normalization principles to reduce redundancy
- Defined:
  - Primary keys for entity identification
  - Foreign keys to enforce relationships
  - Composite keys where applicable
  - Unique and NOT NULL constraints to ensure data quality

---

## Technical Implementation (SQL)

The SQL implementation includes:

- DDL statements for table creation
- Primary key and foreign key definitions
- Constraint enforcement for referential integrity
- Dependency-aware table creation order
- Sample data insertion for validation and testing

The script is designed to execute cleanly without errors in a SQL-compatible relational database.

---

## Data Integrity & Validation
Data integrity is enforced through:

- Primary key constraints to ensure row uniqueness
- Foreign key constraints to maintain valid relationships
- Constraint validation using sample inserts
- Structured dependency management between tables

These mechanisms ensure that invalid rentals, orphan records, and inconsistent data states are prevented.

---

## How to Run
1. Open `database.sql` in a SQL-compatible database environment
2. Execute the script to create tables and constraints
3. Verify schema creation using SELECT queries
4. Validate relationships by reviewing joined query results

---

## Technical Skills Demonstrated
- Relational database design
- ER modeling (conceptual and logical)
- SQL DDL and DML
- Constraint-based data validation
- Schema normalization
- Referential integrity enforcement

---

## Business Value
This database provides a reliable foundation for:
- Rental management systems
- Inventory tracking platforms
- Backend services for event operations
- Future application-layer integrations

---

## Future Enhancements
Potential extensions include:
- Stored procedures for rental workflows
- Triggers to update equipment availability
- Indexing for query performance
- Integration with an application or API layer
- Reporting and analytics queries

---

## Summary
This project represents a complete end-to-end database solution for an event equipment rental business.  
It combines business understanding with technical execution to deliver a structured, scalable, and integrity-driven relational database design.

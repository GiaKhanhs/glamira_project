# Glamira E-Commerce Analytics Platform

## Overview

An end-to-end Data Engineering project that builds a modern analytics platform for e-commerce clickstream and transaction data.

The project ingests raw MongoDB event data, processes it through Google Cloud services and dbt transformations, and implements enterprise-grade data governance controls.

---

## Architecture

### Data Flow

![](/images/Flow.drawio.png)

---

## Technology Stack

| Component       | Technology                         |
| --------------- | ---------------------------------- |
| Source System   | MongoDB                            |
| Data Lake       | Google Cloud Storage               |
| Data Warehouse  | BigQuery                           |
| Transformation  | dbt                                |
| Data Modeling   | Fact Constellation Schema                        |
| Data Governance | Policy Tags + Dynamic Data Masking |
| Cloud Platform  | Google Cloud Platform              |

---

## Data Model

### Fact Tables

#### fact_sales_order_detail

Business grain:
One row per purchased product within an order.

Metrics:

* sales_amount
* order_qty
* unit_price

#### fact_user_event_detail

Business grain:
One row per user event.

Metrics:

* user activity
* website interactions
* conversion tracking

---

### Dimension Tables

* dim_customer
* dim_product
* dim_device
* dim_traffic_source
* dim_date

---

## Data Governance

### Sensitive Data Classification

| Column        | Policy Tag |
| ------------- | ---------- |
| email_address | PII_EMAIL  |
| ip            | PII_IP     |

### Security Controls

Implemented:

* Policy Tags
* Fine-Grained Access Control
* Dynamic Data Masking
* Role-Based Access Control (RBAC)

### Access Model

| User Type         | Access        |
| ----------------- | ------------- |
| Owner             | Raw Data      |
| Masked Reader     | Masked Data   |
| Unauthorized User | Access Denied |

---

## Data Quality

Implemented dbt tests:

* not_null
* unique
* primary key validation
* referential integrity
* data consistency checks

---

## Key Features

* End-to-end ELT pipeline
* Star schema dimensional modeling
* dbt transformations
* Data quality testing
* Dynamic Data Masking
* Role-based access control
* E-commerce behavioral analytics

---

## Fact Constellation Schema Diagram

![](/images/DWH.png)



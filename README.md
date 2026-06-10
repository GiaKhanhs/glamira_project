# Glamira Data Engineering Project Tracker

## Phase 1 - Data Ingestion

### MongoDB → GCS

* [x] Setup MongoDB connection
* [x] Create export script
* [x] Implement checkpoint mechanism
* [x] Export 41M+ records
* [x] Upload partition files to GCS
* [x] Add logging and monitoring
* [x] Validate exported file count

### GCS → BigQuery

* [x] Create BigQuery dataset
* [x] Generate schema_fields.json
* [x] Create load script
* [x] Load all partitions to BigQuery
* [x] Validate row count
* [x] Investigate duplicate records
* [x] Create final deduplicated table

---

# Phase 2 - Data Warehouse Modeling

## dbt Project Setup

* [x] Install dbt-bigquery
* [x] Initialize dbt project
* [x] Configure profiles.yml
* [x] Configure dbt_project.yml
* [x] Validate connection using dbt debug

---

## Staging Layer

### Source Definition

* [x] Create models/staging/sources.yml
* [x] Add source tests

### stg_summary

* [x] Rename columns
* [x] Standardize naming convention
* [x] Cast data types
* [x] Remove duplicate events
* [x] Validate row count

### Data Quality Tests

* [x] event_id not_null
* [x] event_id unique
* [x] event_timestamp not_null
* [x] accepted values for is_paypal
* [x] accepted values for show_recommendation

---

# Phase 3 - Core Layer

## Dimension Tables

### dim_date

* [ ] Create date dimension
* [ ] Generate date_key
* [ ] Add calendar attributes

Columns:

* [ ] date_key
* [ ] event_date
* [ ] year
* [ ] quarter
* [ ] month
* [ ] week_of_year
* [ ] day
* [ ] day_of_week

---

### dim_customer

* [ ] Create customer dimension

Columns:

* [ ] customer_key
* [ ] customer_id
* [ ] email_address

---

### dim_product

* [ ] Create product dimension

Columns:

* [ ] product_key
* [ ] product_id
* [ ] category_id
* [ ] product_price
* [ ] currency_code
* [ ] alloy_value_id
* [ ] diamond_value_id
* [ ] finish_value_id
* [ ] stone_value_id
* [ ] pearl_color_value_id
* [ ] shape_diamond_value_id

---

### dim_device

* [ ] Create device dimension

Columns:

* [ ] device_key
* [ ] device_id
* [ ] ip
* [ ] user_agent
* [ ] resolution

---

### dim_traffic_source

* [ ] Create traffic source dimension

Columns:

* [ ] traffic_source_key
* [ ] utm_source
* [ ] utm_medium
* [ ] referrer_url
* [ ] current_url

---

## Fact Table

### fact_user_event_detail

Grain:

```text
1 row = 1 event
```

Tasks:

* [ ] Generate surrogate keys
* [ ] Join dimensions
* [ ] Create event fact

Foreign Keys:

* [ ] date_key
* [ ] customer_key
* [ ] product_key
* [ ] device_key
* [ ] traffic_source_key

Measures:

* [ ] product_price
* [ ] option_price

Flags:

* [ ] is_paypal
* [ ] show_recommendation

---

# Phase 4 - Security & Governance

## PII Assessment

* [ ] Identify PII columns
* [ ] Review email_address usage
* [ ] Review ip usage

## BigQuery Policy Tags

* [ ] Create taxonomy
* [ ] Create PII tag
* [ ] Apply tag to email_address
* [ ] Apply tag to ip
* [ ] Configure Dynamic Data Masking
* [ ] Test masking behavior

---

# Phase 5 - Data Mart

## mart_product_performance

* [ ] Product views
* [ ] Product revenue
* [ ] Recommendation CTR

---

## mart_traffic_performance

* [ ] Sessions
* [ ] Users
* [ ] Conversions
* [ ] Conversion rate

---

## mart_daily_funnel

* [ ] Daily visitors
* [ ] Product views
* [ ] Add to cart
* [ ] Checkout
* [ ] Checkout success
* [ ] Conversion rate

---

# Phase 6 - Visualization

## Looker Studio

* [ ] Connect BigQuery
* [ ] Create product dashboard
* [ ] Create traffic dashboard
* [ ] Create funnel dashboard

---

# Phase 7 - Documentation

## Technical Documentation

* [ ] Architecture diagram
* [ ] Data model diagram
* [ ] dbt lineage screenshot
* [ ] Data dictionary

## Repository

* [ ] Clean code
* [ ] README
* [ ] Setup guide
* [ ] Screenshots

---

# Stretch Goals

* [ ] Incremental dbt models
* [ ] Cloud Run ingestion
* [ ] Data quality monitoring
* [ ] CI/CD pipeline
* [ ] Partitioned fact table
* [ ] Clustered fact table

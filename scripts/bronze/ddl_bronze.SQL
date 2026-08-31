/*
================================================================================
DDL Script: Create Bronze Tables
================================================================================

Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
================================================================================
*/



IF OBJECT_ID ('bronez.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronez.crm_cust_info ;

CREATE TABLE bronez.crm_cust_info(
	cst_id INT ,
	cst_key NVARCHAR(50) ,
	cst_firstname NVARCHAR(50) ,
	cst_lastname NVARCHAR(50) ,
	cst_marital_status NVARCHAR(50) , 
	cst_gndr NVARCHAR(50) , 
	cst_create_date DATE  
);


IF OBJECT_ID ('bronez.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronez.crm_cust_info ; 

CREATE TABLE bronez.crm_prd_info(

	prd_id INT ,
	prd_key NVARCHAR(50) , 
	prd_nm  NVARCHAR(50) , 
	prd_cost INT ,
	prd_line NVARCHAR(50) ,
	prd_start_dt DATETIME ,
	prd_end_dt DATETIME ,

);

IF OBJECT_ID ('bronez.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronez.crm_cust_info ;

CREATE TABLE bronez.crm_sales_details(
sls_ord_num NVARCHAR(50) ,
sls_prd_key NVARCHAR(50) ,
sls_cust_id INT ,
sls_order_dt INT ,
sls_ship_dt INT ,
sls_due_dt INT ,
sls_sales INT , 
sls_quantity INT ,
sls_price INT 
);

IF OBJECT_ID ('bronez.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronez.crm_cust_info ; 

CREATE TABLE bronez.erp_loc_a101(
CID NVARCHAR(50) ,
CNTRY NVARCHAR(50) 

);

IF OBJECT_ID ('bronez.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronez.crm_cust_info ; 

CREATE TABLE bronez.erp_cust_az12(
CID NVARCHAR(50) ,
BDATE NVARCHAR(50) ,
GEN NVARCHAR(50) 

);

IF OBJECT_ID ('bronez.crm_cust_info' , 'U') IS NOT NULL
	DROP TABLE bronez.crm_cust_info ; 

CREATE TABLE bronez.erp_px_cat_g1v2(

ID NVARCHAR(50) ,
CAT NVARCHAR(50) ,
SUBCAT NVARCHAR(50) , 
MAINTENANCE NVARCHAR(50) 

);


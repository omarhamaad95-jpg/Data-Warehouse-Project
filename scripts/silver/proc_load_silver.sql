/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process
    to populate the Silver layer tables from the Bronze layer.

Actions Performed:
    - Truncates existing data from Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.
    - Handles errors during the loading process.
    - Prints messages and loading duration for each step.
    - Prints the total duration of the Silver layer loading process.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/ 

-- =========================================
-- Create / Alter Silver Loading Procedure
-- =========================================

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

    -- Start measuring total Silver loading duration
    DECLARE @start_time DATETIME2, @end_time DATETIME2;
    DECLARE @step_start_time DATETIME2, @step_end_time DATETIME2;

    SET @start_time = GETDATE();

    PRINT '=========================================';
    PRINT 'Starting Silver Layer Load';
    PRINT '=========================================';


    BEGIN TRY

        -- =========================================
        -- CRM Customer Information
        -- =========================================

        PRINT 'Starting CRM Customer Information...';

        SET @step_start_time = GETDATE();

        TRUNCATE TABLE silver.crm_cust_info;
        PRINT 'crm_cust_info truncated successfully';

        INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
            cst_id, 
            cst_key, 
            TRIM(cst_firstname) AS cst_firstname, 
            TRIM(cst_lastname) AS cst_lastname,

            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' 
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,

            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,

            cst_create_date

        FROM(
            SELECT *,
                ROW_NUMBER() OVER(
                    PARTITION BY cst_id 
                    ORDER BY cst_create_date DESC
                ) AS flag_last 

            FROM bronez.crm_cust_info

            WHERE cst_id IS NOT NULL 
        ) t 

        WHERE flag_last = 1;

        SET @step_end_time = GETDATE();

        PRINT 'CRM Customer Information loaded successfully';
        PRINT 'Duration: ' 
              + CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR)
              + ' seconds';


        -- =========================================
        -- CRM Product Information
        -- =========================================

        PRINT 'Starting CRM Product Information...';

        SET @step_start_time = GETDATE();

        TRUNCATE TABLE silver.crm_prd_info;
        PRINT 'crm_prd_info truncated successfully';

        INSERT INTO silver.crm_prd_info(
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,

            REPLACE(
                SUBSTRING(prd_key, 1, 5),
                '-',
                '_'
            ) AS cat_id,

            SUBSTRING(
                prd_key,
                7,
                LEN(prd_key)
            ) AS prd_key,

            prd_nm,

            ISNULL(prd_cost, 0) AS prd_cost,

            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,

            CAST(prd_start_dt AS DATE) AS prd_start_dt,

            CAST(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ) - 1 AS DATE
            ) AS prd_end_dt

        FROM bronez.crm_prd_info;

        SET @step_end_time = GETDATE();

        PRINT 'CRM Product Information loaded successfully';
        PRINT 'Duration: ' 
              + CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR)
              + ' seconds';


        -- =========================================
        -- CRM Sales Details
        -- =========================================

        PRINT 'Starting CRM Sales Details...';

        SET @step_start_time = GETDATE();

        TRUNCATE TABLE silver.crm_sales_details;
        PRINT 'crm_sales_details truncated successfully';

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT 
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE 
                WHEN sls_order_dt = 0 
                     OR LEN(sls_order_dt) != 8 
                    THEN NULL
                ELSE CAST(
                    CAST(sls_order_dt AS VARCHAR(8)) AS DATE
                )
            END AS sls_order_dt,

            CASE 
                WHEN sls_ship_dt = 0 
                     OR LEN(sls_ship_dt) != 8 
                    THEN NULL
                ELSE CAST(
                    CAST(sls_ship_dt AS VARCHAR(8)) AS DATE
                )
            END AS sls_ship_dt,

            CASE 
                WHEN sls_due_dt = 0 
                     OR LEN(sls_due_dt) != 8 
                    THEN NULL
                ELSE CAST(
                    CAST(sls_due_dt AS VARCHAR(8)) AS DATE
                )
            END AS sls_due_dt,

            CASE 
                WHEN sls_sales IS NULL 
                     OR sls_sales <= 0 
                     OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            CASE 
                WHEN sls_price IS NULL 
                     OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price

        FROM bronez.crm_sales_details;

        SET @step_end_time = GETDATE();

        PRINT 'CRM Sales Details loaded successfully';
        PRINT 'Duration: ' 
              + CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR)
              + ' seconds';


        -- =========================================
        -- ERP Customer
        -- =========================================

        PRINT 'Starting ERP Customer...';

        SET @step_start_time = GETDATE();

        TRUNCATE TABLE silver.erp_cust_az12;
        PRINT 'erp_cust_az12 truncated successfully';

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )
        SELECT

            CASE 
                WHEN CID LIKE 'NAS%' 
                    THEN SUBSTRING(CID, 4, LEN(CID))
                ELSE CID
            END AS cid,

            CASE 
                WHEN BDATE > GETDATE() 
                    THEN NULL 
                ELSE BDATE 
            END AS bdate,

            CASE 
                WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') 
                    THEN 'Female'

                WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') 
                    THEN 'Male'

                ELSE 'n/a'
            END AS gen

        FROM bronez.erp_cust_az12;

        SET @step_end_time = GETDATE();

        PRINT 'ERP Customer loaded successfully';
        PRINT 'Duration: ' 
              + CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR)
              + ' seconds';


        -- =========================================
        -- ERP Location
        -- =========================================

        PRINT 'Starting ERP Location...';

        SET @step_start_time = GETDATE();

        TRUNCATE TABLE silver.erp_loc_a101;
        PRINT 'erp_loc_a101 truncated successfully';

        INSERT INTO silver.erp_loc_a101
        (
            CID,
            CNTRY
        )
        SELECT  

            REPLACE(CID, '-', '') AS CID,

            CASE 
                WHEN TRIM(CNTRY) = 'DE' 
                    THEN 'Germany'

                WHEN TRIM(CNTRY) IN ('US', 'USA') 
                    THEN 'United States'

                WHEN TRIM(CNTRY) = '' 
                     OR CNTRY IS NULL 
                    THEN 'n/a'

                ELSE TRIM(CNTRY)
            END AS CNTRY

        FROM bronez.erp_loc_a101;

        SET @step_end_time = GETDATE();

        PRINT 'ERP Location loaded successfully';
        PRINT 'Duration: ' 
              + CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR)
              + ' seconds';


        -- =========================================
        -- ERP Product Category
        -- =========================================

        PRINT 'Starting ERP Product Category...';

        SET @step_start_time = GETDATE();

        TRUNCATE TABLE silver.erp_px_cat_g1v2;
        PRINT 'erp_px_cat_g1v2 truncated successfully';

        INSERT INTO silver.erp_px_cat_g1v2
        (
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE
        )
        SELECT 
            ID,
            CAT,
            SUBCAT,
            MAINTENANCE

        FROM bronez.erp_px_cat_g1v2;

        SET @step_end_time = GETDATE();

        PRINT 'ERP Product Category loaded successfully';
        PRINT 'Duration: ' 
              + CAST(DATEDIFF(SECOND, @step_start_time, @step_end_time) AS VARCHAR)
              + ' seconds';


        -- =========================================
        -- Loading Completed
        -- =========================================

        SET @end_time = GETDATE();

        PRINT '=========================================';
        PRINT 'Silver Layer loaded successfully';
        PRINT 'Total Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
              + ' seconds';
        PRINT '=========================================';


    END TRY

    BEGIN CATCH

        PRINT '=========================================';
        PRINT 'ERROR OCCURRED WHILE LOADING SILVER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
        PRINT '=========================================';

    END CATCH

END;


EXEC bronez.load_bronze;

EXEC silver.load_silver;

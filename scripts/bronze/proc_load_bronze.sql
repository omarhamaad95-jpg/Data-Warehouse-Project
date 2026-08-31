/*
================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
================================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
        - Truncates the bronze tables before loading data.
        - Uses the `BULK INSERT` command to load data from CSV Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
================================================================================
*/



CREATE OR ALTER PROCEDURE bronez.load_bronze
AS
BEGIN

    DECLARE @start_time DATETIME, @end_time DATETIME;
    DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY

        -- Start Whole Batch Timer
        SET @batch_start_time = GETDATE();

        PRINT '========================================';
        PRINT 'Loading Bronze Layer';
        PRINT '========================================';


        PRINT '----------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------';


        -- CRM Customer
        SET @start_time = GETDATE();

        PRINT '>> TRUNCATE TABLE bronez.crm_cust_info';
        TRUNCATE TABLE bronez.crm_cust_info;

        PRINT '>> INSERTING DATA INTO: bronez.crm_cust_info';

        BULK INSERT bronez.crm_cust_info
        FROM 'C:\Users\LENOVO\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> ----------------------------------------';


        -- CRM Product
        SET @start_time = GETDATE();

        PRINT '>> TRUNCATE TABLE bronez.crm_prd_info';
        TRUNCATE TABLE bronez.crm_prd_info;

        PRINT '>> INSERTING DATA INTO: bronez.crm_prd_info';

        BULK INSERT bronez.crm_prd_info
        FROM 'C:\Users\LENOVO\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> ----------------------------------------';


        -- CRM Sales
        SET @start_time = GETDATE();

        PRINT '>> TRUNCATE TABLE bronez.crm_sales_details';
        TRUNCATE TABLE bronez.crm_sales_details;

        PRINT '>> INSERTING DATA INTO: bronez.crm_sales_details';

        BULK INSERT bronez.crm_sales_details
        FROM 'C:\Users\LENOVO\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> ----------------------------------------';


        PRINT '----------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '----------------------------------------';


        -- ERP Customer
        SET @start_time = GETDATE();

        PRINT '>> TRUNCATE TABLE bronez.erp_cust_az12';
        TRUNCATE TABLE bronez.erp_cust_az12;

        PRINT '>> INSERTING DATA INTO: bronez.erp_cust_az12';

        BULK INSERT bronez.erp_cust_az12
        FROM 'C:\Users\LENOVO\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> ----------------------------------------';


        -- ERP Location
        SET @start_time = GETDATE();

        PRINT '>> TRUNCATE TABLE bronez.erp_loc_a101';
        TRUNCATE TABLE bronez.erp_loc_a101;

        PRINT '>> INSERTING DATA INTO: bronez.erp_loc_a101';

        BULK INSERT bronez.erp_loc_a101
        FROM 'C:\Users\LENOVO\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> ----------------------------------------';


        -- ERP Product Category
        SET @start_time = GETDATE();

        PRINT '>> TRUNCATE TABLE bronez.erp_px_cat_g1v2';
        TRUNCATE TABLE bronez.erp_px_cat_g1v2;

        PRINT '>> INSERTING DATA INTO: bronez.erp_px_cat_g1v2';

        BULK INSERT bronez.erp_px_cat_g1v2
        FROM 'C:\Users\LENOVO\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '>> ----------------------------------------';


        -- End Whole Batch Timer
        SET @batch_end_time = GETDATE();

        PRINT '========================================';
        PRINT '>> Whole Batch Load Duration: '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR)
            + ' seconds';
        PRINT '========================================';

        PRINT 'Bronze Layer Loaded Successfully';
        PRINT '========================================';


    END TRY


    BEGIN CATCH

        PRINT '========================================';
        PRINT 'ERROR OCCURRED LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '========================================';

    END CATCH

END;
GO


EXEC bronez.load_bronze;

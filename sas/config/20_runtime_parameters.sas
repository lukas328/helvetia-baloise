%global g_pipeline_name g_trigger_type g_source_system_default;
%global g_batch_run_id g_step_order g_has_error g_run_status;
%global g_run_date g_reporting_ccy g_reprocess_days g_min_event_date;
%global g_db2_database g_db2_server g_db2_port g_db2_authdomain g_db2_user g_db2_password;
%global g_last_rows_read g_last_rows_written;

%let g_pipeline_name=DM_SALES_PROVISIONING;
%let g_trigger_type=SCHEDULED;
%let g_source_system_default=CORE;

%let g_reporting_ccy=CHF;
%let g_reprocess_days=45;
%let g_run_date=%sysfunc(today(), yymmdd10.);
%let g_min_event_date=%sysfunc(intnx(day,%sysfunc(today()),-&g_reprocess_days,b), yymmddn8.);

%let g_batch_run_id=.;
%let g_step_order=0;
%let g_has_error=0;
%let g_run_status=RUNNING;

%let g_db2_database=INSDWH;
%let g_db2_server=db2prd01.corp.local;
%let g_db2_port=50000;
%let g_db2_authdomain=DB2_PROD_SVC;
%let g_db2_user=svc_sas_dm;
%let g_db2_password=%sysget(DB2_SVC_PASSWORD);

%let g_last_rows_read=0;
%let g_last_rows_written=0;

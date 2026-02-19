%macro _assign_lib(libref=, schema=);
  %if %length(%superq(g_db2_password)) > 0 %then %do;
    libname &libref db2
      database="&g_db2_database"
      server="&g_db2_server"
      port=&g_db2_port
      schema=&schema
      user="&g_db2_user"
      password="&g_db2_password"
      connection=shared
      read_isolation_level=cs;
  %end;
  %else %do;
    libname &libref db2
      database="&g_db2_database"
      server="&g_db2_server"
      port=&g_db2_port
      schema=&schema
      authdomain="&g_db2_authdomain"
      connection=shared
      read_isolation_level=cs;
  %end;
%mend;

%_assign_lib(libref=DWHCORE, schema=DWH_CORE);
%_assign_lib(libref=DMVERS, schema=DM_VERSICHERUNG);
%_assign_lib(libref=CTLINS, schema=CTL_INS);
%_assign_lib(libref=WRKINS, schema=WRK_INS);

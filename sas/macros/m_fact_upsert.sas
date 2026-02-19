%macro m_fact_upsert(src_ds=, tgt_ds=, natural_key_cols=);
  %global g_last_rows_read g_last_rows_written;
  %local i l_col l_join_cond l_first_col;

  %if %length(%superq(src_ds))=0 or %length(%superq(tgt_ds))=0 or %length(%superq(natural_key_cols))=0 %then %do;
    %put ERROR: [m_fact_upsert] Missing mandatory parameters.;
    %let g_has_error=1;
    %return;
  %end;

  %let g_last_rows_read=0;
  %let g_last_rows_written=0;

  %let l_join_cond=;
  %let i=1;
  %let l_col=%scan(%superq(natural_key_cols),&i,%str( ));
  %do %while(%length(&l_col) > 0);
    %if &i=1 %then %do;
      %let l_first_col=&l_col;
      %let l_join_cond=s.&l_col = t.&l_col;
    %end;
    %else %let l_join_cond=&l_join_cond and s.&l_col = t.&l_col;

    %let i=%eval(&i+1);
    %let l_col=%scan(%superq(natural_key_cols),&i,%str( ));
  %end;

  proc sql noprint;
    select count(*) into :g_last_rows_read trimmed from &src_ds;

    create table work._fact_to_insert as
    select s.*
    from &src_ds s
    left join &tgt_ds t
      on &l_join_cond
    where t.&l_first_col is null;

    select count(*) into :g_last_rows_written trimmed from work._fact_to_insert;
  quit;

  proc append base=&tgt_ds data=work._fact_to_insert force;
  run;

  %put NOTE: [m_fact_upsert] src=&src_ds tgt=&tgt_ds read=&g_last_rows_read inserted=&g_last_rows_written;
%mend;

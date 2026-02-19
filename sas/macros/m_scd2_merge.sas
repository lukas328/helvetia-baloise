%macro m_scd2_merge(src_ds=, tgt_ds=, bk_cols=, hash_cols=, valid_from_col=gueltig_von);
  %local i l_col l_join_cond l_first_bk l_set_clause;

  %if %length(%superq(src_ds))=0 or %length(%superq(tgt_ds))=0 or %length(%superq(bk_cols))=0 %then %do;
    %put ERROR: [m_scd2_merge] Missing mandatory parameters.;
    %let g_has_error=1;
    %return;
  %end;

  %let l_join_cond=;
  %let i=1;
  %let l_col=%scan(%superq(bk_cols),&i,%str( ));
  %do %while(%length(&l_col) > 0);
    %if &i=1 %then %do;
      %let l_first_bk=&l_col;
      %let l_join_cond=s.&l_col = t.&l_col;
    %end;
    %else %let l_join_cond=&l_join_cond and s.&l_col = t.&l_col;

    %let i=%eval(&i+1);
    %let l_col=%scan(%superq(bk_cols),&i,%str( ));
  %end;

  proc sql;
    create table work._scd2_to_insert as
    select s.*
    from &src_ds s
    left join &tgt_ds t
      on &l_join_cond
     and s.&valid_from_col = t.&valid_from_col
    where t.&l_first_bk is null;
  quit;

  proc append base=&tgt_ds data=work._scd2_to_insert force;
  run;

  %if %length(%superq(hash_cols)) > 0 %then %do;
    %let l_set_clause=;
    %let i=1;
    %let l_col=%scan(%superq(hash_cols),&i,%str( ));

    %do %while(%length(&l_col) > 0);
      %if &i=1 %then %let l_set_clause=&l_col = (select s.&l_col from &src_ds s where &l_join_cond and s.&valid_from_col = t.&valid_from_col);
      %else %let l_set_clause=&l_set_clause, &l_col = (select s.&l_col from &src_ds s where &l_join_cond and s.&valid_from_col = t.&valid_from_col);

      %let i=%eval(&i+1);
      %let l_col=%scan(%superq(hash_cols),&i,%str( ));
    %end;

    proc sql;
      update &tgt_ds t
      set &l_set_clause
      where exists (
        select 1
        from &src_ds s
        where &l_join_cond
          and s.&valid_from_col = t.&valid_from_col
      );
    quit;
  %end;
%mend;

%macro m_lookup_key(src_ds=, dim_ds=, out_ds=, join_expr=, date_expr=, dim_key_col=, out_key_col=resolved_key);
  %if %length(%superq(src_ds))=0 or %length(%superq(dim_ds))=0 or %length(%superq(out_ds))=0 %then %do;
    %put ERROR: [m_lookup_key] Missing mandatory parameters.;
    %let g_has_error=1;
    %return;
  %end;

  proc sql;
    create table &out_ds as
    select
      s.*,
      d.&dim_key_col as &out_key_col
    from &src_ds s
    left join &dim_ds d
      on (&join_expr)
     and (&date_expr between d.gueltig_von and d.gueltig_bis);
  quit;
%mend;

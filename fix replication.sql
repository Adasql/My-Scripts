--fix replication issues


EXEC sys.sp_repldone
        @xactid = NULL
      , @xact_seqno = NULL
      , @numtrans= 0
      , @time= 0
      , @reset= 1;
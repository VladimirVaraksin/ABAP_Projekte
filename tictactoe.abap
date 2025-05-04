DATA:
  f0        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f1        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f2        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f3        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f4        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f5        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f6        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f7        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  f8        TYPE z32324_107_tictactoe_feld_de VALUE '_',
  i1        TYPE z32324_107_tictactoe_eingabde,
  nachricht TYPE c LENGTH 30,
  ok_code   TYPE sy-ucomm.


SET SCREEN 100.


CLASS lcl_spiel DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: neue_starten, zug, check_ende, change_player.

  PRIVATE SECTION.
    CLASS-DATA: spieler TYPE c LENGTH 1 VALUE 'X', ende TYPE boolean.
ENDCLASS.


CLASS lcl_spiel IMPLEMENTATION.
  METHOD neue_starten.
    f0 = '_'.
    f1 = '_'.
    f2 = '_'.
    f3 = '_'.
    f4 = '_'.
    f5 = '_'.
    f6 = '_'.
    f7 = '_'.
    f8 = '_'.
    spieler = 'X'.
    nachricht = ''.
    ende = abap_false.
  ENDMETHOD.

  METHOD zug.
    IF ende = abap_true.
      RETURN.
    ENDIF.

    DATA: str TYPE string.
    str = spieler.

    CASE i1.
      WHEN '0'.
        IF f0 = '_'.
          f0 = str.
          change_player( ).
        ENDIF.
      WHEN '1'.
        IF f1 = '_'.
          f1 = str.
          change_player( ).
        ENDIF.
      WHEN '2'.
        IF f2 = '_'.
          f2 = str.
          change_player( ).
        ENDIF.
      WHEN '3'.
        IF f3 = '_'.
          f3 = str.
          change_player( ).
        ENDIF.
      WHEN '4'.
        IF f4 = '_'.
          f4 = str.
          change_player( ).
        ENDIF.
      WHEN '5'.
        IF f5 = '_'.
          f5 = str.
          change_player( ).
        ENDIF.
      WHEN '6'.
        IF f6 = '_'.
          f6 = str.
          change_player( ).
        ENDIF.
      WHEN '7'.
        IF f7 = '_'.
          f7 = str.
          change_player( ).
        ENDIF.
      WHEN '8'.
        IF f8 = '_'.
          f8 = str.
          change_player( ).
        ENDIF.
    ENDCASE.
    check_ende( ).

  ENDMETHOD.

  METHOD change_player.
    IF spieler = 'X'.
      spieler = 'O'.
    ELSE.
      spieler = 'X'.
    ENDIF.
  ENDMETHOD.

  METHOD check_ende.
    DATA: str   TYPE string, char TYPE c, i TYPE i, index TYPE i.
    CONCATENATE f0 f1 f2 f3 f4 f5 f6 f7 f8 INTO str.
    DO 9 TIMES.
      index = sy-index - 1.
      char = str+index(1).
      IF char EQ '_'.
        EXIT.
      ELSE.
        i += 1.
      ENDIF.
    ENDDO.
    IF i = 9.
      ende = abap_true.
      nachricht = 'Unentschieden!'.
    ENDIF.
    IF f0 = f1 AND f1 = f2 AND f2 NE '_' OR
      f3 = f4 AND f4 = f5 AND f5 NE '_' OR
      f6 = f7 AND f7 = f8 AND f8 NE '_' OR
      f0 = f3 AND f3 = f6 AND f6 NE '_' OR
      f1 = f4 AND f4 = f7 AND f7 NE '_' OR
      f2 = f5 AND f5 = f8 AND f8 NE '_' OR
      f0 = f4 AND f4 = f8 AND f8 NE '_' OR
      f2 = f4 AND f4 = f6 AND f6 NE '_'.
      change_player( ).
      CONCATENATE 'Spieler '  spieler  ' hat gewonnen!' INTO nachricht SEPARATED BY space.
      ende = abap_true.
    ENDIF.
  ENDMETHOD.
ENDCLASS.



MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'NEUE'.
      lcl_spiel=>neue_starten( ).
    WHEN 'ZUG'.
      lcl_spiel=>zug( ).
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
ENDMODULE.

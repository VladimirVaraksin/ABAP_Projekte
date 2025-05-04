REPORT Z32324107_HANGMAN_HTML.

TABLES: z32324107_hm_wds.

CLASS lcl_hangman DEFINITION DEFERRED.

DATA: eingabe        TYPE z32324107_hangman_eingabe_de,
      ok_code        TYPE sy-ucomm,
      nachricht      TYPE string, nachrichtEnd TYPE string, lettersUsed  TYPE string,
      numGuesses     TYPE i,
      test           TYPE c LENGTH 10,
      display_word   TYPE c LENGTH 60,
      lcl_hangman_sp TYPE REF TO lcl_hangman.

***für Galgen
DATA: str1   TYPE string,
      str2   TYPE string,
      str2_1 TYPE string,
      str2_2 TYPE string,
      str2_3 TYPE string,
      str2_4 TYPE string,
      str2_5 TYPE string,
      str2_6 TYPE string,
      str2_7 TYPE string,
      str2_8 TYPE string,
      str2_9 TYPE string,
      str3   TYPE string,
      str4   TYPE string,
      str4_1 TYPE string,
      str5   TYPE string,
      str5_1 TYPE string,
      str5_2 TYPE string,
      str5_3 TYPE string,
      str6   TYPE string,
      str6_1 TYPE string,
      str6_2 TYPE string,
      str7   TYPE string.



SET SCREEN 100.


CLASS lcl_hangman DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: randomInt RETURNING VALUE(r_i) TYPE i,
      pickWord IMPORTING im_index TYPE i RETURNING VALUE(r_word) TYPE z32324107_hm_wds-word.

    METHODS: constructor IMPORTING im_word TYPE z32324107_hm_wds-word,
      displayHidden,
      zug,
      checkEnded RETURNING VALUE(r_gameWon) TYPE boolean,
      displayGalgen,
      checkUsed RETURNING VALUE(r_used) TYPE boolean.

  PRIVATE SECTION.
    DATA: word        TYPE c LENGTH 10, length TYPE i, hidden_word  TYPE c LENGTH 10.
ENDCLASS.

CLASS lcl_hangman IMPLEMENTATION.

  METHOD constructor.
    word = im_word.
    length = strlen( word ).

    str1 = str2 = str3 = str2_1 = str2_2 = str2_3 = str2_4 = str2_5 = str2_6 = str2_7 = str2_8 = str2_9 = str3 = str4 = str4_1 = str5 = str5_1 = str5_2 = str5_3 = str6 = str6_1 = str6_2 = str7 = ''.
    nachricht = nachrichtend = lettersused = display_word = ''.
    numGuesses = 0.

    hidden_word = repeat( val = '_' occ = length ).
    displayhidden( ).
  ENDMETHOD.
*Zufallszahl generieren und zurückgeben
  METHOD randomInt.
    DATA(rnd_obj) = cl_abap_random_int=>create(
      seed = sy-uzeit + 1
      min  = 1
      max  = 81
    ).
    DO 5 TIMES.
      DATA(l_r) = rnd_obj->get_next( ).
    ENDDO.
    r_i = l_r.
  ENDMETHOD.

*Ein Wort mit Index im_index aus der Tabelle z32324107_hm_wds zurückgeben
  METHOD pickWord.
    DATA: itab TYPE TABLE OF z32324107_hm_wds, wa LIKE LINE OF itab.

    SELECT * FROM z32324107_hm_wds INTO TABLE itab.

    READ TABLE itab INDEX im_index INTO wa.

    r_word = wa-word.
  ENDMETHOD.

  METHOD displayHidden.
    display_word = ''.
    DO length TIMES.
      DATA(index) = sy-index - 1.
      CONCATENATE display_word hidden_word+index(1) INTO display_word SEPARATED BY space.
    ENDDO.
  ENDMETHOD.
* Methode, um einen Zug zu machen (=einen Buchstaben zu raten)
  METHOD zug.
    DATA index TYPE i.
*   prüfen, ob das Spiel beendet ist oder der Spieler schon 7 mal falschen Buchstaben eingegeben hat
    IF checkEnded( ) = abap_true OR numGuesses >= 7 OR eingabe EQ '' OR word EQ ''.
      RETURN.
    ENDIF.
*   überprüfen, ob diesen Buchstaben schon eingegeben wurde
    IF checkused( ) = abap_true.
      nachricht = 'Diesen Buchstaben haben Sie bereits verwendet!'.
      RETURN.
    ENDIF.

*   überprüfen, ob den eingegebenen Buchstaben richtig ist
    IF word CA to_lower( eingabe ).
      DO length TIMES.
        index = sy-index - 1. "Schleifenindex beginnt mit 1, und der Index einer String soll mit 0 beginnen, deswegen um 1 dekrementieren
        IF word+index(1) EQ to_lower( eingabe ).
          CONCATENATE 'Buchstabe: ' eingabe ' ist korrekt :)' INTO nachricht SEPARATED BY space.
          hidden_word+index(1) = word+index(1).
        ENDIF.
      ENDDO.
    ELSE.
      numGuesses += 1.
      CONCATENATE 'Buchstabe: ' eingabe ' ist nicht korrekt :(' INTO nachricht SEPARATED BY space.
    ENDIF.

    CONCATENATE lettersused eingabe INTO lettersused SEPARATED BY space.

    IF checkEnded( ) EQ abap_true.
      nachrichtend = 'Sie haben das Spiel gewonnen!'.
    ELSEIF numguesses >= 7.
      CONCATENATE 'Sie haben leider verloren. Das Wort war: '  word INTO nachrichtend  SEPARATED BY space.
    ENDIF.

    displayhidden( ).
    displaygalgen( ).
  ENDMETHOD.

  METHOD checkUsed.
    IF lettersused CA eingabe.
      r_used = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD checkEnded.
    IF word EQ '' OR hidden_word CA '_'.
      RETURN.
    ENDIF.
    r_gameWon = abap_true.
  ENDMETHOD.


*Methode, um einen Galgen anzuzeigen. Die Lösung ist nicht perfekt.
  METHOD displayGalgen.
    CASE numguesses.
      WHEN 1.
        str1 = repeat( val = '-' occ = 70 ).
      WHEN 2.
        str2 = str2_1 = str2_2 = str2_3 = str2_4 = str2_5 = str2_6 = str2_7 = str2_8 = str2_9 = repeat( val = '-' occ = 5 ).
      WHEN 3.
        str3 = repeat( val = '-' occ = 70 ).
      WHEN 4.
        str4 = str4_1 = repeat( val = '-' occ = 8 ).
      WHEN 5.
        str5 = ' | '.
        str5_1 = '***'.
        str5_2 = '* *'.
        str5_3 = ' * '.
      WHEN 6.
        str6 = ' | '.
        str6_1 = repeat( val = '-' occ = 12 ).
        str6_2 = str6.
      WHEN 7.
        str7 = '|__________|'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE ok_code.
    WHEN 'FNEU'.
      lcl_hangman_sp = NEW lcl_hangman( lcl_hangman=>pickword( lcl_hangman=>randomint( ) ) ).
    WHEN 'FZUG'.
      IF lcl_hangman_sp IS NOT INITIAL.
        lcl_hangman_sp->zug( ).
      ELSE.
        lcl_hangman_sp = NEW lcl_hangman( lcl_hangman=>pickword( lcl_hangman=>randomint( ) ) ).
      ENDIF.
    WHEN 'FBACK'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '100'.
  SET TITLEBAR '100'.
ENDMODULE.

REPORT z32324107_prak10_1.

TABLES: z32324107_cities.


CLASS ex_tank_leer DEFINITION INHERITING FROM cx_static_check.
  PUBLIC SECTION.
    DATA local_text TYPE string.
    METHODS constructor IMPORTING f_spritmenge TYPE i.
ENDCLASS.

CLASS ex_tank_leer IMPLEMENTATION.
  METHOD constructor.
    DATA: text             TYPE string,
          f_spritmenge_str TYPE string.
    f_spritmenge_str = f_spritmenge.
    CONCATENATE 'Fehlende Spritmenge für Ihre Reise: ' f_spritmenge_str ' Liter' INTO text SEPARATED BY space.
    super->constructor( ).
    local_text = text.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_auto DEFINITION.
  PUBLIC SECTION.

    TYPES: ty_tinh TYPE p LENGTH 5 DECIMALS 2.

    CLASS-DATA: itab_auto TYPE TABLE OF REF TO lcl_auto.

    EVENTS: e_unfall, e_tank_leer. " EXPORTING VALUE(ex_kennzeichen) TYPE string

    METHODS: constructor
      IMPORTING im_k TYPE string
                im_h TYPE string
                im_f TYPE string
                im_t TYPE ty_tinh
                im_v TYPE i
                im_s TYPE string,
      get_kennzeichen RETURNING VALUE(rv_k) TYPE string,
      get_hersteller RETURNING VALUE(rv_h) TYPE string,
      get_farbe RETURNING VALUE(rv_f) TYPE string,
      get_standort RETURNING VALUE(rv_s) TYPE string,
      get_kmstand RETURNING VALUE(rv_km) TYPE i,
      get_tageskm RETURNING VALUE(rv_tkm) TYPE i,
      get_tankgroesse RETURNING VALUE(rv_tgr) TYPE i,
      get_tankinhalt RETURNING VALUE(rv_tinh) TYPE ty_tinh,
      get_verbrauch RETURNING VALUE(rv_v) TYPE i,
      tanken
        IMPORTING im_tinh TYPE i,
      fahren
        IMPORTING im_zielort TYPE z32324107_cities-zielort,
      reset_tageskmstand,
      auto_info,
      adac_tanken,
      tank_leeren.

    CLASS-METHODS:
      main,
      ausgabe_itab_autos,
      random_integer RETURNING VALUE(rv_int) TYPE i.

  PRIVATE SECTION.

    DATA:
      kennzeichen    TYPE string,
      hersteller     TYPE string,
      farbe          TYPE string,
      standort       TYPE string,
      kmzaehler      TYPE i,
      tageskmzaehler TYPE i,
      tankgroesse    TYPE i,
      tankinhalt     TYPE ty_tinh,
      verbrauch      TYPE i. " wie viele L pro 100 KM

ENDCLASS.

CLASS lcl_auto IMPLEMENTATION.

  METHOD constructor.
    kennzeichen = im_k.
    farbe = im_f.
    hersteller = im_h.
    standort   = im_s.
    tankgroesse    = im_t.
    verbrauch = im_v.
  ENDMETHOD.
***Getter Methoden
  METHOD get_kennzeichen.
    rv_k = kennzeichen.
  ENDMETHOD.

  METHOD get_standort.
    rv_s = standort.
  ENDMETHOD.

  METHOD get_hersteller.
    rv_h = hersteller.
  ENDMETHOD.

  METHOD get_farbe.
    rv_f = farbe.
  ENDMETHOD.

  METHOD get_kmstand.
    rv_km = kmzaehler.
  ENDMETHOD.

  METHOD get_tageskm.
    rv_tkm = tageskmzaehler.
  ENDMETHOD.

  METHOD get_tankgroesse.
    rv_tgr = tankgroesse.
  ENDMETHOD.

  METHOD get_tankinhalt.
    rv_tinh = tankinhalt.
  ENDMETHOD.

  METHOD get_verbrauch.
    rv_v = verbrauch.
  ENDMETHOD.

  method adac_tanken.
    tankinhalt += 5.
  endmethod.

  method tank_leeren.
  tankinhalt = 0.
  endmethod.

***Methode zum Fahren
  METHOD fahren.
    DATA:
      wa           TYPE z32324107_cities,
      l_km_max     TYPE i,
      lo_excp      TYPE REF TO ex_tank_leer,
      lv_excp_text TYPE string,
      lv_ran_int   TYPE i.

    l_km_max = tankinhalt / verbrauch * 100.

    SELECT * FROM z32324107_cities INTO wa WHERE zielort = im_zielort.
    ENDSELECT.

    IF sy-subrc <> 0.
      WRITE: 'Zielort ', im_zielort, ' nicht gefunden'.
    ENDIF.

    lv_ran_int = lcl_auto=>random_integer( ).

    IF lv_ran_int <= 30.
      WRITE: /, 'Ein Unfall ist mit deinem Auto', kennzeichen , ' passiert :o'.
      RAISE EVENT e_unfall.
    ENDIF.
*    TRY.
    IF wa-km <= l_km_max.
      standort = im_zielort.
      tankinhalt = tankinhalt -  ( wa-km / 100 * verbrauch ).
      kmzaehler += wa-km.
      tageskmzaehler += wa-km.
    ELSE.
*          RAISE EXCEPTION TYPE ex_tank_leer
*            EXPORTING
*              f_spritmenge = ( wa-km - l_km_max ) / verbrauch.
      RAISE EVENT e_tank_leer.
    ENDIF.
*      CATCH ex_tank_leer INTO lo_excp.
*        IF lo_excp IS NOT INITIAL.
*          lv_excp_text = lo_excp->local_text.
*          MESSAGE lv_excp_text TYPE 'I'.
*        ENDIF.
*ENDTRY.
  ENDMETHOD.

  METHOD random_integer.
    CALL FUNCTION 'QF05_RANDOM_INTEGER'
      EXPORTING
        ran_int_max   = 100
        ran_int_min   = 1
      IMPORTING
        ran_int       = rv_int
      EXCEPTIONS
        invalid_input = 1
        OTHERS        = 2.

    IF sy-subrc <> 0.
      MESSAGE 'Invalid Input oder andere Fehler' TYPE 'I'.
    ENDIF.
  ENDMETHOD.

***Methode zum Tanken
  METHOD tanken.
    DATA: l_ueber_spritmenge TYPE i,
          lo_excp            TYPE REF TO zcx_32324_107_tank_voll,
          lv_excp_text       TYPE string.
    l_ueber_spritmenge = im_tinh - tankgroesse + tankinhalt.
    TRY.
        IF im_tinh + tankinhalt > tankgroesse.
          tankinhalt = tankgroesse.
          RAISE EXCEPTION TYPE zcx_32324_107_tank_voll
            EXPORTING
              max_tank         = tankgroesse
              ueber_spritmenge = l_ueber_spritmenge.
        ENDIF.
        tankinhalt += im_tinh.
      CATCH zcx_32324_107_tank_voll INTO lo_excp.
        IF lo_excp IS NOT INITIAL.
          lv_excp_text = lo_excp->get_text( ).
          MESSAGE lv_excp_text TYPE 'I'.
        ENDIF.
    ENDTRY.
  ENDMETHOD.

***Methode um Kilometerstand zurückzusetzen
  METHOD reset_tageskmstand.
    tageskmzaehler = 0.
  ENDMETHOD.

  METHOD auto_info.
    WRITE: /, 'Hersteller: ', hersteller, '| Kennzeichen: ', kennzeichen, '| Standort: ', standort, '| Kilometerstand: ',  kmzaehler, '| Tankinhalt: ', tankinhalt, '| Verbrauch: ', verbrauch.
  ENDMETHOD.

***Methode um alle Autos auszugeben
  METHOD ausgabe_itab_autos.
    ULINE.
    WRITE 'Alle funktionierenden Autos'.
    ULINE.
    LOOP AT lcl_auto=>itab_auto INTO DATA(ref_auto).
      ref_auto->auto_info( ).
    ENDLOOP.
  ENDMETHOD.

***Main Methode
  METHOD main.
    DATA: lcl_bmw TYPE REF TO lcl_auto,
          kn      TYPE string.

    DO 10 TIMES.
      kn = 'AU AB000' && sy-index.
      lcl_bmw = NEW lcl_auto( im_k = kn im_h = 'BMW' im_f = 'Schwarz' im_t = 90 im_v = sy-index im_s = 'Augsburg' ).
      APPEND lcl_bmw TO itab_auto.
    ENDDO.

  ENDMETHOD.
ENDCLASS.

CLASS lcl_adac DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: register TYPE TABLE OF REF TO lcl_auto.

    CLASS-METHODS: on_tank_leer FOR EVENT e_tank_leer OF lcl_auto IMPORTING sender,
      mitglied_werden IMPORTING im_auto TYPE REF TO lcl_auto,
      mitglieder.
ENDCLASS.

CLASS lcl_adac IMPLEMENTATION.
  METHOD mitglieder.
    ULINE.
    WRITE 'ADAC Mitglieder'.
    ULINE.
    LOOP AT lcl_adac=>register INTO DATA(ref_auto).
      ref_auto->auto_info( ).
    ENDLOOP.
  ENDMETHOD.

  METHOD on_tank_leer.
    DATA: lv_found       TYPE abap_bool,
          lv_kennzeichen TYPE string.

    lv_kennzeichen = sender->get_kennzeichen( ).

    LOOP AT register INTO DATA(ref_auto).
      IF ref_auto->get_kennzeichen( ) = lv_kennzeichen.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.


    IF lv_found = abap_true.
      sender->adac_tanken( ).
      WRITE: /, 'Hallo von ADAC! Dein Auto ', sender->get_kennzeichen( ),' wird mit 5L getankt:)'.
    ELSE.
    sender->tank_leeren( ).
      WRITE: /, 'Der Tank von deinem Auto (', sender->get_kennzeichen( ), ') ist leer und du bist kein ADAC-Mitglied:(' .
    ENDIF.
  ENDMETHOD.

  METHOD mitglied_werden.
    APPEND im_auto TO register.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_polizei DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA: register TYPE TABLE OF REF TO lcl_auto.

    CLASS-METHODS: on_unfall FOR EVENT e_unfall OF lcl_auto IMPORTING sender,
      auto_ausgabe.
ENDCLASS.

CLASS lcl_polizei IMPLEMENTATION.
  METHOD on_unfall.
    APPEND sender TO register.
    DELETE lcl_auto=>itab_auto WHERE table_line = sender.
  ENDMETHOD.


  METHOD auto_ausgabe.
    ULINE.
    WRITE 'Autos bei der Polizei'.
    ULINE.
    LOOP AT lcl_polizei=>register INTO DATA(ref_auto).
      ref_auto->auto_info( ).
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  lcl_auto=>main( ).
  LOOP AT lcl_auto=>itab_auto INTO DATA(ref_auto).
    SET HANDLER lcl_adac=>on_tank_leer FOR ref_auto.
    SET HANDLER lcl_polizei=>on_unfall FOR ref_auto.

    IF lcl_auto=>random_integer( ) > 50.
      lcl_adac=>mitglied_werden( ref_auto ).
    ENDIF.

    ref_auto->tanken( 10 ).
    ref_auto->fahren( 'Nürnberg' ).
  ENDLOOP.

  lcl_adac=>mitglieder( ).
  lcl_auto=>ausgabe_itab_autos( ).
  lcl_polizei=>auto_ausgabe( ).

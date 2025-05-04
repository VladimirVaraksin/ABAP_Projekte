*&---------------------------------------------------------------------*
*& Report Z32324107_HANGMAN_HTML
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z32324107_HANGMAN_HTML.

CLASS lcl_utils DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS: randomInt RETURNING VALUE(r_i) TYPE i,
      pickWord IMPORTING im_index TYPE i RETURNING VALUE(r_word) TYPE z32324107_hm_wds-word.
ENDCLASS.

CLASS lcl_utils IMPLEMENTATION.
*Zufallszahl generieren und zurückgeben
  METHOD randomInt.
    DATA(rnd_obj) = cl_abap_random_int=>create(
      seed = sy-uzeit + 1
      min  = 1
      max  = 81
    ).

    DATA(l_r) = rnd_obj->get_next( ).

    r_i = l_r.
  ENDMETHOD.

*Ein Wort mit Index im_index aus der Tabelle z32324107_hm_wds zurückgeben
  METHOD pickWord.
    DATA: itab TYPE TABLE OF z32324107_hm_wds, wa LIKE LINE OF itab.

    SELECT * FROM z32324107_hm_wds INTO TABLE itab.

    READ TABLE itab INDEX im_index INTO wa.

    r_word = wa-word.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_hangman DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS main.
  PRIVATE SECTION.
ENDCLASS.

CLASS lcl_hangman IMPLEMENTATION.
  METHOD main.
    DATA error_list TYPE cl_abap_browser=>html_table.
    DATA(word) = lcl_utils=>pickWord( lcl_utils=>randomInt( ) ).

    DATA(html_str) =
           `<html>`
        && `  <head>`
        && `    <meta http-equiv="content-type" content="text/html; charset=utf-8">`
        && `    <style>`
        && `      .gallow { position: relative; width: 200px; height: 300px; margin: 20px auto; }`
        && `      .base { position: absolute; bottom: 0; width: 100%; height: 10px; background: #333; }`
        && `      .pole { position: absolute; bottom: 10px; left: 30px; width: 10px; height: 280px; background: #333; }`
        && `      .top-beam { position: absolute; top: 0; left: 30px; width: 100px; height: 10px; background: #333; }`
        && `      .rope { position: absolute; top: 10px; left: 120px; width: 2px; height: 40px; background: #555; display: none; }`
        && `      .head { position: absolute; top: 50px; left: 105px; width: 30px; height: 30px; border-radius: 50%; border: 3px solid black; display: none; }`
        && `      .body { position: absolute; top: 83px; left: 121px; width: 2px; height: 60px; background: black; display: none; }`
        && `      .arm.left { position: absolute; top: 90px; left: 111px; width: 2px; height: 30px; background: black; transform: rotate(-45deg); display: none; }`
        && `      .arm.right { position: absolute; top: 90px; left: 131px; width: 2px; height: 30px; background: black; transform: rotate(45deg); display: none; }`
        && `      .leg.left { position: absolute; top: 140px; left: 111px; width: 2px; height: 30px; background: black; transform: rotate(45deg); display: none; }`
        && `      .leg.right { position: absolute; top: 140px; left: 131px; width: 2px; height: 30px; background: black; transform: rotate(-45deg); display: none; }`
        && `    </style>`
        && `    <script>`
        && `      let word = "` && word && `".toLowerCase();`
        && `      let displayWord = Array(word.length).fill("_");`
        && `      let wrongGuesses = 0;`
        && `      let usedLetters = [];`
        && `      const maxWrong = 7;`
        && `      function updateDisplay() {`
        && `        document.getElementById("wordDisplay").innerText = displayWord.join(" ");`
        && `        document.getElementById("usedLetters").innerText = "Benutzte Buchstaben: " + usedLetters.join(", ");`
        && `        document.getElementById("remainingTries").innerText = "Verbleibende Versuche: " + (maxWrong - wrongGuesses);`
        && `      }`
        && `      function showPart(n) {`
        && `        const parts = ["rope", "head", "body", "arm left", "arm right", "leg left", "leg right"];`
        && `        const part = document.getElementsByClassName(parts[n])[0];`
        && `        if (part) part.style.display = "block";`
        && `      }`
        && `      function guessLetter() {`
        && `        const input = document.getElementById("letterInput");`
        && `        const letter = input.value.toLowerCase();`
        && `        input.value = "";`
        && `        if (!/^[a-z]$/.test(letter)) {`
        && `          document.getElementById("feedback").innerText = "Buchstaben a–z eingeben."; return; }`
        && `        if (usedLetters.includes(letter)) {`
        && `          document.getElementById("feedback").innerText = "Buchstabe wurde bereits verwendet."; return;`
        && `        }`
        && `        usedLetters.push(letter);`
        && `        let found = false;`
        && `        for (let i = 0; i < word.length; i++) {`
        && `          if (word[i] === letter) { displayWord[i] = letter; found = true; }`
        && `        }`
        && `        if (found) {`
        && `          document.getElementById("feedback").innerText = "✅ Richtiger Buchstabe!";`
        && `        } else {`
        && `          showPart(wrongGuesses);`
        && `          wrongGuesses++;`
        && `          document.getElementById("feedback").innerText = "❌ Falscher Buchstabe!";`
        && `        }`
        && `        updateDisplay();`
        && `        if (!displayWord.includes("_")) {`
        && `          document.getElementById("message").innerText = "🎉 Gewonnen!"; endGame();`
        && `        } else if (wrongGuesses >= maxWrong) {`
        && `          document.getElementById("message").innerText = "Verloren! Das Wort war: " + word; endGame();`
        && `        }`
        && `      }`
        && `      function endGame() {`
        && `        document.getElementById("guessButton").disabled = true;`
        && `        document.getElementById("letterInput").disabled = true;`
        && `      }`
        && `      window.onload = updateDisplay;`
        && `    </script>`
        && `  </head>`
        && `  <body>`
        && `    <div class="gallow">`
        && `      <div class="base"></div>`
        && `      <div class="pole"></div>`
        && `      <div class="top-beam"></div>`
        && `      <div class="rope"></div>`
        && `      <div class="head"></div>`
        && `      <div class="body"></div>`
        && `      <div class="arm left"></div>`
        && `      <div class="arm right"></div>`
        && `      <div class="leg left"></div>`
        && `      <div class="leg right"></div>`
        && `    </div>`
        && `    <div id="wordDisplay" style="text-align:center;font-size:24px;margin:20px;"></div>`
        && `    <div style="text-align:center;">`
        && `      <input type="text" id="letterInput" maxlength="1">`
        && `      <button id="guessButton" onclick="guessLetter()">Buchstaben raten</button>`
        && `    </div>`
        && `    <div id="feedback" style="text-align:center;color:#0066cc;font-weight:bold;margin-top:10px;"></div>`
        && `    <div id="message" style="text-align:center;font-weight:bold;margin-top:10px;"></div>`
        && `    <div id="usedLetters" style="text-align:center;margin-top:10px;"></div>`
        && `    <div id="remainingTries" style="text-align:center;margin-top:10px;"></div>`
        && `  </body>`
        && `</html>`.



    cl_abap_browser=>show_html(
      EXPORTING
        html_string = html_str
        title       = 'Hangman Spiel'
      IMPORTING
         html_errors = error_list ).

    IF error_list IS NOT INITIAL.
      MESSAGE 'Error in HTML' TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  lcl_hangman=>main( ).

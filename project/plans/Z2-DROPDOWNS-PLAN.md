# Z2-DROPDOWNS Plan

## Scope
Pro Vorkommen von `UmsatzTypInput` separat bewerten.
GUI-Bezeichnung ist führend, Code-Stelle dient nur der Zuordnung.
Bearbeitungsreihenfolge: `Z2.1 -> Z2.2 -> Z2.3`.

## Sub-Ziele
1. `Z2.1` Umsätze-Übersicht: Filter „Kategorie“ (`<Alle Kategorien>`)
   Code: `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/KontoauszugList.java`
2. `Z2.2` Umsatz-Detailansicht: Feld „Kategorie“
   Code: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzDetailControl.java`
3. `Z2.3` Umsatzkategorie-Detail: Feld „Übergeordnete Kategorie“
   Code: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzTypControl.java`

## Z2.1 Verhaltens-Invarianten (muss unverändert bleiben)
1. Filter-Verknüpfung bleibt AND-basiert:
   Kategorie-Filter wirkt zusätzlich zu Konto/Kontogruppe/Zeitraum/Gegenkonto/Betrag/Zweck/Suchbegriff.
2. Auto-Reload bleibt erhalten:
   UI-Änderungen an den Filtern triggern weiterhin die Aktualisierung über den bestehenden Listener-Mechanismus (kein neuer separater „Suchen“-Button).
3. Checkbox-Verhalten bleibt erhalten:
   `Untergeordnete Kategorien einbeziehen` triggert weiterhin ein Reload und beeinflusst ausschließlich die Kategorie-Matchlogik.
4. Enable/Disable-Regel bleibt erhalten:
   Checkbox ist nur aktiv, wenn eine konkrete Kategorie gewählt ist; bei `<Alle Kategorien>` bleibt sie deaktiviert.
5. Semantik bleibt erhalten:
   - Ohne Checkbox: exakte Kategorie.
   - Mit Checkbox: gewählte Kategorie plus untergeordnete Kategorien (über Parent-Kette).
6. Cache-/Persistenzverhalten bleibt erhalten:
   bestehende Werte für Kategorie und Unterkategorien-Option werden wie bisher verwendet.

## Testfälle (für Z2.1 Plan ergänzen)
1. Kategorie gesetzt, Checkbox aus: nur exakte Kategorie.
2. Kategorie gesetzt, Checkbox an: Kategorie + Unterkategorien.
3. Checkbox umschalten: Ergebnisliste aktualisiert sich ohne manuellen Such-Button.
4. Kategorie auf `<Alle Kategorien>`: Checkbox deaktiviert, kein Kategorie-Matchfilter aktiv.
5. Kombination mit anderem Filter (z. B. Zeitraum): Ergebnis entspricht AND-Verknüpfung.
6. Kategorie auf `<nicht zugeordnet>`: nur Umsätze ohne zugeordnete Kategorie.

## Annahmen
1. Z2.1 ändert nur die Kategorie-Auswahl-UI, nicht die bestehende Reload-/Filterlogik.
2. Bestehender Debounce/Delayed-Listener bleibt unverändert aktiv.

## Z2.1 Ist-Stand (umgesetzt)
1. Das lange Kategorie-Dropdown wurde ersetzt durch ein read-only Anzeigefeld mit `...`-Button.
2. Die Auswahl erfolgt über das bestehende Muster aus dem Dialog „Auswahl der Kategorie“.
3. Pseudokategorien sind verfügbar:
   - `<Alle Kategorien>`
   - `<nicht zugeordnet>`
4. Die Anzeige nutzt einen gekürzten Pfad mit sichtbarem Basename.
5. Filterlogik bleibt unverändert:
   - AND-Verknüpfung mit den übrigen Filtern
   - Auto-Reload über den bestehenden Listener-Mechanismus
   - bestehende Checkbox-Semantik für Unterkategorien bleibt erhalten

## Z2.1 Testabnahme
1. Testmodus: interaktiv.
2. Ergebnis: alle Testfälle erfolgreich.
3. Geprüft:
   - exakte Kategorie (Checkbox aus)
   - Kategorie plus Unterkategorien (Checkbox an)
   - `<Alle Kategorien>`
   - `<nicht zugeordnet>`
   - AND-Kombinationen mit Zeitraum/Suchbegriff
   - Auto-Reload ohne separaten Such-Button
   - Regression der übrigen Filterfunktionen

## PR-Readiness (Z2.1)
1. Geänderte Datei:
   - `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/KontoauszugList.java`
2. Leitplanken erfüllt:
   - keine DB-Änderung
   - keine Matching-Änderung
   - keine Encoding-Migration
3. Hinweis:
   - `hibiscus/.project` bleibt bewusst unstaged und außerhalb des Z2.1-PR-Scope.

## Z2.2 Plan (Umsatz-Detailansicht: Feld "Kategorie")
1. Ziel:
   - Die lange Dropdown-Auswahl im Feld `Kategorie` der Umsatz-Detailansicht wird UI-seitig analog zu Z2.1 verbessert.
   - Bedienmuster: read-only Anzeigefeld plus `...`-Button und Dialog "Auswahl der Kategorie".
2. Scope:
   - In Scope: `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzDetailControl.java`.
   - Out of Scope: DB, Matching-Logik, weitere Views/Controller, Encoding.
3. Wichtige Abweichung zu Z2.1:
   - Kein Sonderfall `<nicht zugeordnet>` als zusätzlicher UI-Eintrag.
4. Umsetzung:
   - Bisheriges `UmsatzTypInput` im Feld `Kategorie` durch lokales read-only Input mit `...` ersetzen.
   - `...` öffnet `UmsatzTypListDialog` unter Beibehaltung der bisherigen Typ-Filterlogik.
   - Null-/Leerfall bleibt fachlich als "keine Kategorie" möglich.
   - Pfadanzeige wie bei Z2.1 gekürzt, Basename bleibt sichtbar.
5. Invarianten:
   - Speichern bleibt unverändert über `u.setUmsatzTyp((UmsatzTyp)getUmsatzTyp().getValue())`.
   - Disable-Regel bei `Umsatz.FLAG_NOTBOOKED` bleibt unverändert.
   - Keine Änderung an fachlicher Zuordnung/Filterung.
6. Testfälle:
   - Kategorie ändern bei bereits zugeordnetem Umsatz.
   - Kategorie setzen bei bislang leerer Kategorie.
   - Kategorie entfernen (`null`) und speichern.
   - Kein `<nicht zugeordnet>`-Sonderpunkt sichtbar.
   - Notbooked-Umsatz bleibt nicht editierbar.
   - Regressionstest: übrige Felder/Speichern unverändert.
7. PR-Readiness (Z2.2):
   - Erwartete Ziel-Dateien:
     - `hibiscus/src/de/willuhn/jameica/hbci/gui/controller/UmsatzDetailControl.java`
     - `hibiscus/src/de/willuhn/jameica/hbci/gui/dialogs/UmsatzTypListDialog.java` (Dialog-Positionierung auf Vorauswahl)
   - Leitplanken: keine DB-Änderung, keine Matching-Änderung, keine Encoding-Migration.

## Z2.2 Ist-Stand (umgesetzt)
1. Das Kategorie-Feld in der Umsatz-Detailansicht wurde von langem Dropdown auf read-only Anzeigefeld mit `...`-Button umgestellt.
2. Die Auswahl erfolgt über den bestehenden Dialog „Auswahl der Kategorie“.
3. Kein zusätzlicher Sonderpunkt `<nicht zugeordnet>` in Z2.2.
4. Null-/Leerfall bleibt fachlich als „keine Kategorie“ möglich.
5. Die Anzeige nutzt einen gekürzten Pfad mit sichtbarem Basename.
6. Zusätzliche Usability-Verbesserung im Dialog:
   - bei vorausgewählter Kategorie wird auf die markierte Zeile positioniert (Scroll-Position wird gesetzt).
7. Fachliche Logik bleibt unverändert:
   - Speicherung weiterhin über `setUmsatzTyp(...)`
   - Disable-Verhalten bei `Umsatz.FLAG_NOTBOOKED` unverändert

## Z2.2 Testabnahme
1. Testmodus: interaktiv.
2. Ergebnis: alle Testfälle erfolgreich.
3. Geprüft:
   - Kategorie ändern bei bereits zugeordnetem Umsatz
   - Kategorie setzen bei leerer Kategorie
   - Kategorie entfernen (`Keine Kategorie`)
   - kein `<nicht zugeordnet>`-Sonderpunkt in Z2.2
   - Feld bei `FLAG_NOTBOOKED` weiterhin nicht editierbar
   - Dialog positioniert auf die vorausgewählte Kategorie
   - Regression: Speichern/Zurück und übrige Felder unverändert

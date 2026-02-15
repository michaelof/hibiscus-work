# Hibiscus: Umsatzkategorien - Findings (Code + Usability)

## Kontext
- Workspace enthält `hibiscus` (Fachlogik/GUI) und `jameica` (Plattform-Basis).
- Relevante Logik zu Umsatzkategorien liegt in `hibiscus`.

## Kurzfazit
- Die fachliche Kategorisierungslogik ist leistungsfähig (manuell + dynamisch, Konto-/Gruppenbezug, Regeln).
- Der größte Engpass liegt in der GUI-Auswahl bei großen und gedoppelten Bäumen.

## Architekturverständnis (aus Code)
- Zentrales Domänenobjekt: `UmsatzTyp` (Kategorie als Baumknoten, mit Typ, Pattern, Kommentar, Farben, Flags).
- Umsatzzuordnung:
  - Fest zugeordnet über `umsatztyp_id` (manuelle Zuordnung).
  - Sonst dynamische Ermittlung über `matches(...)` der Kategorien.
- Dynamisches Matching berücksichtigt u.a.:
  - Einnahme/Ausgabe-Kompatibilität mit Betrag.
  - Optionales Scope auf Konto oder Kontogruppe.
  - Suchbegriffe (Token) oder Regex über mehrere Felder (Verwendungszweck, Gegenkonto, IDs, Kommentar, Art, etc.).
- Es gibt eine virtuelle Kategorie `Nicht zugeordnet`.
- Flag `FLAG_SKIP_REPORTS` blendet Kategorien in Auswertungsbäumen aus.

## Usability-Status (Ist)
- **Manuelle Zuordnung in Umsatzliste:** gut.
  - Nutzt `UmsatzTypListDialog` mit Suchfeld.
  - Option: Unterkategorien von Treffern anzeigen.
- **Filter in Umsatz-Übersicht:** unbefriedigend bei großem Baum.
  - Nutzt `UmsatzTypInput` als vollständiges Dropdown über den gesamten Kategoriebaum.
  - Bei vielen Knoten/ähnlichen Namen schwer bedienbar.
- **Admin/Pflege Umsatzkategorien (Einstellungen):** nur bedingt skalierbar.
  - Tree wird vollständig angezeigt.
  - Keine expliziten Fold-/Collapse-All-Steuerungen in dieser Ansicht.

## Warum der Pain Point strukturell auftritt
- In realen Haushaltsbuch-Bäumen gibt es bewusst semantische Dopplungen unter verschiedenen Pfaden.
- Ein einzelner Baum wird für mehrere Dimensionen genutzt (praktisch Netzbedarf auf Baumstruktur gemappt).
- Dadurch reicht die reine Anzeige des Knotennamens oft nicht; Pfadkontext wird für sichere Auswahl wichtig.

## Konkrete Verbesserungsideen (klein, wirksam)
1. Filterauswahl in `KontoauszugList` von Dropdown auf suchbaren Dialog umstellen (analog manuelle Zuordnung).
2. In Kategoriepflege explizite Aktionen ergänzen: `Alle aufklappen` / `Alle zuklappen`.
3. Pfadorientierte Anzeige in Auswahlkontexten stärken (wo sinnvoll standardmäßig).

## Relevante Code-Stellen
- Navigation Auswertung: `hibiscus/plugin.xml`
- Kategorie-Interface: `hibiscus/src/de/willuhn/jameica/hbci/rmi/UmsatzTyp.java`
- Matching/Regeln: `hibiscus/src/de/willuhn/jameica/hbci/server/UmsatzTypImpl.java`
- Umsatz-Zuordnung: `hibiscus/src/de/willuhn/jameica/hbci/server/UmsatzImpl.java`
- Suchdialog Zuordnung: `hibiscus/src/de/willuhn/jameica/hbci/gui/dialogs/UmsatzTypListDialog.java`
- Action manuelle Zuordnung: `hibiscus/src/de/willuhn/jameica/hbci/gui/action/UmsatzAssign.java`
- Filter-Dropdown Umsatzübersicht: `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/KontoauszugList.java`
- Kategorie-Dropdown Input: `hibiscus/src/de/willuhn/jameica/hbci/gui/input/UmsatzTypInput.java`
- Kategoriepflege-Tree: `hibiscus/src/de/willuhn/jameica/hbci/gui/parts/UmsatzTypTree.java`
- Settings-Einbindung: `hibiscus/src/de/willuhn/jameica/hbci/gui/views/Settings.java`

## Dateinamens-Empfehlung
- Für den aktuellen Zweck ist `FINDINGS.md` passender als `ARCHITECTURE.md`.
- Begründung: Inhalt ist primär Analyse-/Beobachtungsstand (Ist-Zustand, Pain Points, Hypothesen, Next Steps), nicht stabile Ziel-/Systemarchitektur.

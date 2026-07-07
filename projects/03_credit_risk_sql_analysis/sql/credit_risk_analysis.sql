-- ============================================================
-- PROJEKTSTRUKTUR / ROTER FADEN DES ABSCHLUSSPROJEKTS
-- ============================================================
--
-- Dieses SQL-Skript ist nicht nur eine Sammlung einzelner Abfragen,
-- sondern bewusst wie ein kleines Analyseprojekt aufgebaut.
-- Die Reihenfolge der Codebloecke folgt einer klaren Logik:
--
-- TEIL A - ORIENTIERUNG UND DATENVERSTAENDNIS
-- Ziel:
-- Zuerst wird geprueft, ob mit der richtigen Datenbank und der
-- richtigen Tabelle gearbeitet wird. Danach wird die Struktur der
-- Spalten und ein erster kleiner Einblick in die Daten geholt.
-- Warum?
-- Bevor man inhaltlich etwas bewertet, muss man sicher sein, dass die
-- Datenbasis stimmt und man den Datensatz grundsaetzlich verstanden hat.
--
-- TEIL B - DATENQUALITAET UND PLAUSIBILITAET
-- Ziel:
-- In diesem Teil wird der Datensatz auf moegliche Fehler, Ausreisser
-- und fehlende Werte untersucht.
-- Warum?
-- Fehlerhafte oder unplausible Daten koennen spaetere Analysen
-- verfaelschen. Darum wird zuerst geprueft, ob z. B. Alter,
-- Beschaeftigungsdauer, Einkommen oder Zinssaetze auffaellig sind.
--
-- TEIL C - FACHLICHE RISIKOANALYSE
-- Ziel:
-- Jetzt wird untersucht, welche Merkmale im Datensatz tatsaechlich mit
-- hoeheren Kreditausfaellen zusammenhaengen.
-- Warum?
-- Nicht jede auffaellige Spalte ist automatisch ein echter
-- Risikofaktor. Deshalb werden Kreditquote, fruehere Defaults,
-- Loan Grades, Kredithistorie, Beschaeftigungsdauer, Wohnsituation
-- und Zinssatz einzeln geprueft.
--
-- TEIL D - ENTWICKLUNG DER RISIKOLOGIK
-- Ziel:
-- Aus den vorher gefundenen starken Risikofaktoren wird schrittweise
-- eine eigene CASE-WHEN-Risikologik fuer 'Hohes Risiko',
-- 'Mittleres Risiko' und 'Niedriges Risiko' aufgebaut.
-- Warum?
-- Die neue Einteilung soll nicht willkuerlich sein, sondern direkt aus
-- den Analyseergebnissen hergeleitet werden. Verschiedene Varianten
-- werden getestet und miteinander verglichen.
--
-- TEIL E - FINALES MODELL UND ENDRESULTATE
-- Ziel:
-- Die beste finale Logik wird in einer VIEW gespeichert und danach
-- sauber zusammengefasst ausgewertet.
-- Warum?
-- So liegt am Ende eine feste, verstaendliche Modellversion vor, die
-- man in der Praesentation, im Gespraech mit dem Lehrer und spaeter bei
-- Rueckfragen nachvollziehbar erklaeren kann.
--
-- KURZ GESAGT:
-- Dieses Projekt ist von oben nach unten so aufgebaut:
-- 1. Datenbasis pruefen
-- 2. Datenqualitaet pruefen
-- 3. Risikofaktoren analysieren
-- 4. Eigene Risikologik entwickeln
-- 5. Finale Modellversion festhalten und erklaeren
--
-- Dadurch kann es sich klar zeigen:
-- - Was war meine Aufgabenstellung?
-- - Wie bin ich logisch vorgegangen?
-- - Welche Befunde habe ich gefunden?
-- - Wie habe ich daraus meine finale SQL-Logik gebaut?
--

-- ============================================================
-- GRUNDLAGE UND ERSTER UEBERBLICK
-- ============================================================

-- ABSCHNITT 1: ORIENTIERUNG UND GRUNDLAGE
-- Mit USE waehlen wir die Datenbank aus, in der wir arbeiten wollen.
-- Das ist wichtig, damit alle naechsten Abfragen wirklich auf dem richtigen Datensatz laufen.
-- Ab jetzt beziehen sich unsere SELECT-Abfragen auf die Datenbank credit_risk_dataset.
USE credit_risk_dataset;


-- Hier pruefen wir zuerst die Gesamtzahl der Zeilen in der Tabelle credit_risk.
-- COUNT(*) zaehlt einfach alle Datensaetze.
-- Damit kontrollieren wir, ob der Datensatz vollstaendig geladen wurde und ob wir mit der richtigen Tabelle arbeiten.
SELECT COUNT(*) AS anzahl_zeilen
FROM credit_risk;


-- Diese Abfrage zeigt die Struktur der Tabelle.
-- SHOW COLUMNS listet fuer jede Spalte den Namen, den Datentyp und ob NULL-Werte erlaubt sind.
-- So verstehen wir zuerst die Datenbasis, bevor wir inhaltliche Analysen machen.
SHOW COLUMNS FROM credit_risk;


-- Jetzt schauen wir uns die ersten 10 Zeilen direkt an.
-- SELECT * zeigt alle Spalten, LIMIT 10 begrenzt die Ausgabe auf nur wenige Beispiele.
-- Das hilft, ein erstes Gefuehl fuer die Daten zu bekommen, ohne gleich den ganzen Datensatz anzuzeigen.
SELECT * FROM credit_risk LIMIT 10;


-- Mit DISTINCT holen wir alle verschiedenen Werte der Wohnsituation heraus.
-- So sehen wir schnell, welche Kategorien in person_home_ownership ueberhaupt vorkommen.
-- Das ist spaeter wichtig fuer Vergleiche zwischen RENT, OWN, MORTGAGE oder OTHER.
SELECT DISTINCT person_home_ownership
FROM credit_risk;


-- Hier sammeln wir alle verschiedenen Loan Grades ohne Duplikate.
-- So sehen wir, welche alten Bonitaetsbewertungen im Datensatz vorhanden sind.
-- Das ist wichtig, weil wir spaeter alte Grades mit unserer neuen Risikologik vergleichen.
SELECT DISTINCT loan_grade
FROM credit_risk;


-- Diese Abfrage zeigt, welche Werte die Spalte fuer fruehere Zahlungsausfaelle enthaelt.
-- Durch DISTINCT sehen wir nur die verschiedenen Auspraegungen, zum Beispiel Y oder N.
-- So pruefen wir, ob die Spalte sauber und logisch codiert ist.
SELECT DISTINCT cb_person_default_on_file
FROM credit_risk;


-- ============================================================
-- DATENQUALITAET UND PLAUSIBILITAET
-- ============================================================

-- Jetzt analysieren wir die Spalte person_age auf sehr einfache Weise.
-- MIN zeigt das kleinste Alter, MAX das groesste und AVG den Durchschnitt.
-- ROUND rundet den Durchschnitt auf 2 Nachkommastellen, damit das Ergebnis besser lesbar ist.
-- So erkennen wir schnell, ob es unrealistische Alterswerte gibt.
SELECT
    MIN(person_age) AS min_alter,
    MAX(person_age) AS max_alter,
    ROUND(AVG(person_age), 2) AS durchschnitt_alter
FROM credit_risk;


-- Hier zaehlen wir gezielt alle Datensaetze mit einem Alter ueber 100.
-- Die WHERE-Bedingung filtert nur diese auffaelligen Faelle heraus.
-- So sehen wir, ob extreme Alterswerte nur Einzelfaelle oder ein echtes Datenqualitaetsproblem sind.
SELECT COUNT(*) AS anzahl_alter_ueber_100
FROM credit_risk
WHERE person_age > 100;


-- Nachdem wir die Anzahl auffaelliger Alterswerte kennen, schauen wir uns die betroffenen Zeilen direkt an.
-- SELECT * zeigt alle Spalten, damit wir sehen koennen, ob neben dem Alter noch weitere Auffaelligkeiten vorhanden sind.
-- So wird aus einer Zahl ein konkreter inhaltlicher Befund.
SELECT *
FROM credit_risk
WHERE person_age > 100;


-- Jetzt pruefen wir die Dauer der aktuellen Beschaeftigung person_emp_length.
-- Wieder betrachten wir Minimum, Maximum und Durchschnitt.
-- Damit sehen wir schnell, ob extreme oder unplausible Werte wie sehr lange Beschaeftigungszeiten vorkommen.
SELECT
    MIN(person_emp_length) AS min_beschaeftigung,
    MAX(person_emp_length) AS max_beschaeftigung,
    ROUND(AVG(person_emp_length), 2) AS durchschnitt_beschaeftigung
FROM credit_risk;


-- Diese Abfrage prueft eine fachlich wichtige Unmoeglichkeit.
-- Wenn die aktuelle Beschaeftigungsdauer groesser ist als das Alter, kann etwas nicht stimmen.
-- Darum zaehlen wir genau diese Faelle mit COUNT(*) und einer Spalten-gegen-Spalten-Bedingung.
SELECT COUNT(*) AS anzahl_beschaeftigung_groesser_als_alter
FROM credit_risk
WHERE person_emp_length > person_age;


-- Jetzt zeigen wir die Zeilen, in denen die Beschaeftigungsdauer groesser als das Alter ist.
-- So koennen wir die konkreten Datensaetze ansehen und spaeter sauber beschreiben.
-- Das ist wichtig, weil reine Zahlen allein oft noch nicht genug erklaeren.
SELECT *
FROM credit_risk
WHERE person_emp_length > person_age;


-- Hier pruefen wir fehlende Werte in mehreren wichtigen Spalten gleichzeitig.
-- CASE WHEN ... IS NULL THEN 1 ELSE 0 END erzeugt fuer jede Zeile entweder eine 1 oder 0.
-- SUM addiert diese Einsen und gibt damit die Anzahl der NULL-Werte pro Spalte aus.
-- So erkennen wir schnell, in welchen Bereichen der Datensatz unvollstaendig ist.
SELECT
    SUM(CASE WHEN person_age IS NULL THEN 1 ELSE 0 END) AS null_alter,
    SUM(CASE WHEN person_income IS NULL THEN 1 ELSE 0 END) AS null_einkommen,
    SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) AS null_beschaeftigung,
    SUM(CASE WHEN loan_int_rate IS NULL THEN 1 ELSE 0 END) AS null_zinssatz,
    SUM(CASE WHEN loan_percent_income IS NULL THEN 1 ELSE 0 END) AS null_kreditquote,
    SUM(CASE WHEN loan_grade IS NULL THEN 1 ELSE 0 END) AS null_grade
FROM credit_risk;


-- Diese Abfrage geht einen Schritt weiter und berechnet nicht nur die Anzahl, sondern auch den Anteil fehlender Werte.
-- So koennen wir besser einschaetzen, wie gross das Problem wirklich ist.
-- Ein paar fehlende Werte sind etwas anderes als fast jede zehnte Zeile ohne Zinssatz.
SELECT
    COUNT(*) AS gesamt,
    SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) AS null_beschaeftigung,
    ROUND(SUM(CASE WHEN person_emp_length IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS prozent_null_beschaeftigung,
    SUM(CASE WHEN loan_int_rate IS NULL THEN 1 ELSE 0 END) AS null_zinssatz,
    ROUND(SUM(CASE WHEN loan_int_rate IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS prozent_null_zinssatz
FROM credit_risk;


-- Jetzt betrachten wir die Einkommensspalte person_income mit einfachen Kennzahlen.
-- Minimum, Maximum und Durchschnitt helfen uns, moegliche Ausreisser zu erkennen.
-- Vor allem ein extrem hoher Maximalwert kann den Datensatz oder den Durchschnitt verzerren.
SELECT
    MIN(person_income) AS min_einkommen,
    MAX(person_income) AS max_einkommen,
    ROUND(AVG(person_income), 2) AS durchschnitt_einkommen
FROM credit_risk;


-- Mit dieser Abfrage zaehlen wir Einkommen ueber 1.000.000.
-- Die Grenze ist hier bewusst hoch gewaehlt, um nur extreme Faelle zu markieren.
-- So pruefen wir, ob das sehr hohe Einkommen ein einzelner Sonderfall oder eine kleine Gruppe von Ausreissern ist.
SELECT COUNT(*) AS anzahl_einkommen_ueber_1000000
FROM credit_risk
WHERE person_income > 1000000;


-- Jetzt schauen wir uns alle extrem hohen Einkommen direkt an.
-- ORDER BY person_income DESC sortiert vom groessten zum kleinsten Einkommen.
-- So sehen wir zuerst die auffaelligsten Faelle und koennen besser beurteilen, ob sie plausibel wirken.
SELECT *
FROM credit_risk
WHERE person_income > 1000000
ORDER BY person_income DESC;


-- Hier vergleichen wir den Durchschnitt des Einkommens mit und ohne extreme Einkommen ueber 1.000.000.
-- Der erste Durchschnitt nutzt alle Zeilen.
-- Der zweite Durchschnitt ignoriert extreme Einkommen, weil CASE WHEN fuer diese Zeilen NULL zurueckgibt und AVG NULL-Werte nicht mitrechnet.
-- So sehen wir, ob Ausreisser den Durchschnitt stark oder nur leicht verzerren.
SELECT
    ROUND(AVG(person_income), 2) AS durchschnitt_mit_ausreissern,
    ROUND(AVG(CASE WHEN person_income <= 1000000 THEN person_income END), 2) AS durchschnitt_ohne_extreme_einkommen
FROM credit_risk;


-- ============================================================
-- RISIKOFAKTOREN EINZELN PRUEFEN
-- ============================================================

-- Jetzt analysieren wir die Kreditquote loan_percent_income.
-- Diese Spalte zeigt, wie gross der Kredit im Verhaeltnis zum Jahreseinkommen ist.
-- Mit Minimum, Maximum und Durchschnitt bekommen wir einen ersten Ueberblick ueber die Spannweite und das typische Niveau.
SELECT
    MIN(loan_percent_income) AS min_kreditquote,
    MAX(loan_percent_income) AS max_kreditquote,
    ROUND(AVG(loan_percent_income), 2) AS durchschnitt_kreditquote
FROM credit_risk;


-- Hier zaehlen wir, wie viele Kredite mehr als 50 Prozent des Jahreseinkommens ausmachen.
-- Das ist eine bewusst strenge Schwelle, weil solche Faelle fachlich deutlich riskanter wirken koennen.
-- Zusammen mit dem Prozentanteil sehen wir sofort, ob das nur Randfaelle oder ein relevanter Problembereich sind.
SELECT
    COUNT(*) AS gesamt,
    SUM(CASE WHEN loan_percent_income > 0.50 THEN 1 ELSE 0 END) AS anzahl_kreditquote_ueber_50_prozent,
    ROUND(SUM(CASE WHEN loan_percent_income > 0.50 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS prozent_kreditquote_ueber_50_prozent
FROM credit_risk;


-- Jetzt pruefen wir, ob eine hohe Kreditquote auch wirklich mit mehr Ausfaellen zusammenhaengt.
-- CASE teilt den Datensatz in zwei Gruppen: ueber 50 Prozent und 50 Prozent oder weniger.
-- AVG(loan_status) funktioniert hier wie eine Ausfallquote, weil loan_status nur 0 oder 1 ist.
-- Mit GROUP BY vergleichen wir beide Gruppen direkt.
SELECT
    CASE
        WHEN loan_percent_income > 0.50 THEN 'Über 50%'
        ELSE '50% oder weniger'
    END AS kreditquote_gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY kreditquote_gruppe;


-- Diese Abfrage vergleicht Kreditnehmer mit und ohne dokumentierten frueheren Zahlungsausfall.
-- Auch hier lesen wir AVG(loan_status) als Ausfallquote.
-- So pruefen wir, ob die Vergangenheit des Kreditnehmers ein starker Risikofaktor ist.
SELECT
    cb_person_default_on_file,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY cb_person_default_on_file;


-- Jetzt untersuchen wir die alten Loan Grades A bis G.
-- Wir gruppieren nach loan_grade und berechnen fuer jeden Grade die Anzahl der Faelle und die Ausfallquote.
-- ORDER BY loan_grade sortiert die Ergebnisse sauber von A nach G.
-- So sehen wir, ob das bestehende Bewertungssystem im Durchschnitt sinnvoll ansteigt.
SELECT
    loan_grade,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY loan_grade
ORDER BY loan_grade;


-- Diese Abfrage sucht sehr strenge Warnfaelle innerhalb guter alter Grades A oder B.
-- Wir verlangen gleichzeitig einen frueheren Default Y und eine sehr hohe Kreditquote ueber 50 Prozent.
-- Wenn hier Zeilen auftauchen, waeren das starke Hinweise auf moegliche Fehlbewertungen trotz gutem Grade.
SELECT *
FROM credit_risk
WHERE loan_grade IN ('A', 'B')
  AND cb_person_default_on_file = 'Y'
  AND loan_percent_income > 0.50
ORDER BY loan_grade, loan_percent_income DESC;


-- Da die vorige Suche sehr streng war, lockern wir den Filter hier etwas.
-- Es reicht jetzt schon, wenn ein Fall in A oder B mindestens eines der beiden Warnsignale hat: frueherer Default oder hohe Kreditquote.
-- LIMIT 20 begrenzt die Ausgabe auf wenige Beispielzeilen, damit die Tabelle lesbar bleibt.
SELECT *
FROM credit_risk
WHERE loan_grade IN ('A', 'B')
  AND (
      cb_person_default_on_file = 'Y'
      OR loan_percent_income > 0.50
  )
ORDER BY loan_grade, loan_percent_income DESC
LIMIT 20;


-- Jetzt machen wir den Befund innerhalb von A und B messbar.
-- Wir teilen A/B in zwei Gruppen: mit Kreditquote ueber 50 Prozent und mit Kreditquote bis 50 Prozent.
-- Dann vergleichen wir die Ausfallquoten beider Gruppen.
-- So sehen wir, ob hohe Kreditquote sogar innerhalb guter Grades stark negativ wirkt.
SELECT
    CASE
        WHEN loan_percent_income > 0.50 THEN 'A/B mit Kreditquote über 50%'
        ELSE 'A/B mit Kreditquote 50% oder weniger'
    END AS gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE loan_grade IN ('A', 'B')
GROUP BY gruppe;


-- Hier pruefen wir dasselbe Prinzip fuer den Faktor frueherer Default innerhalb von A und B.
-- Wir wollen wissen, ob A/B mit Y deutlich riskanter sind als A/B ohne Y.
-- Das hilft zu verstehen, welche Faktoren die guten Grades noch einmal aufspalten.
SELECT
    CASE
        WHEN cb_person_default_on_file = 'Y' THEN 'A/B mit frueherem Default'
        ELSE 'A/B ohne frueheren Default'
    END AS gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE loan_grade IN ('A', 'B')
GROUP BY gruppe;


-- Mit dieser kurzen Kontrollabfrage pruefen wir direkt, ob es in A oder B ueberhaupt Faelle mit frueherem Default Y gibt.
-- Das ist wichtig, weil eine fehlende Gruppe in einer vorherigen GROUP-BY-Ausgabe sonst missverstanden werden koennte.
SELECT COUNT(*) AS anzahl_ab_mit_default_y
FROM credit_risk
WHERE loan_grade IN ('A', 'B')
  AND cb_person_default_on_file = 'Y';


-- Jetzt betrachten wir die Laenge der Kredithistorie insgesamt.
-- Minimum, Maximum und Durchschnitt geben uns einen ersten Eindruck, ob die Historie eher kurz, lang oder gemischt ist.
-- Das ist spaeter wichtig, weil eine kurze Historie weniger Informationen fuer die Bank bedeutet.
SELECT
    MIN(cb_person_cred_hist_length) AS min_kredithistorie,
    MAX(cb_person_cred_hist_length) AS max_kredithistorie,
    ROUND(AVG(cb_person_cred_hist_length), 2) AS durchschnitt_kredithistorie
FROM credit_risk;


-- Diese Abfrage teilt die Kredithistorie in kurz und laenger auf.
-- Die Schwelle liegt hier bei 4 Jahren, weil wir eine einfache und gut erklaerbare Trennung wollten.
-- Danach vergleichen wir wieder die Ausfallquoten der beiden Gruppen.
SELECT
    CASE
        WHEN cb_person_cred_hist_length <= 4 THEN 'Kurze Kredithistorie (<= 4)'
        ELSE 'Laengere Kredithistorie (> 4)'
    END AS gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY gruppe;


-- Jetzt testen wir die Beschaeftigungsdauer als Risikofaktor.
-- Wir teilen in kurze Beschaeftigung bis 1 Jahr und laengere Beschaeftigung ueber 1 Jahr.
-- NULL-Werte werden vorher ausgeschlossen, damit fehlende Daten den Vergleich nicht verfaelschen.
SELECT
    CASE
        WHEN person_emp_length <= 1 THEN 'Kurze Beschaeftigung (<= 1 Jahr)'
        ELSE 'Laengere Beschaeftigung (> 1 Jahr)'
    END AS gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE person_emp_length IS NOT NULL
GROUP BY gruppe;


-- Hier vergleichen wir die Ausfallquote nach Wohnsituation.
-- GROUP BY person_home_ownership erzeugt je eine Zeile fuer RENT, OWN, MORTGAGE und OTHER.
-- ORDER BY ausfallquote_prozent DESC sortiert die riskanteste Wohnsituation nach oben.
SELECT
    person_home_ownership,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY person_home_ownership
ORDER BY ausfallquote_prozent DESC;


-- Jetzt pruefen wir den Zinssatz als moeglichen Risikotreiber.
-- Wir teilen in hohe Zinssaetze ab 15 Prozent und niedrigere Zinssaetze unter 15 Prozent.
-- NULL-Werte werden ausgeschlossen, weil ein fehlender Zinssatz hier keinen sinnvollen Gruppenvergleich erlaubt.
SELECT
    CASE
        WHEN loan_int_rate >= 15 THEN 'Hoher Zinssatz (>= 15)'
        ELSE 'Niedrigerer Zinssatz (< 15)'
    END AS gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE loan_int_rate IS NOT NULL
GROUP BY gruppe;


-- ============================================================
-- AUFBAU DER ERSTEN RISIKOLOGIK
-- ============================================================

-- Das ist der erste harte Kern fuer 'Hohes Risiko'.
-- Wir verlangen gleichzeitig zwei sehr starke Warnsignale: hohe Kreditquote ueber 50 Prozent und hoher Zinssatz ab 15 Prozent.
-- Das Ergebnis zeigt, ob diese extrem strenge Kombination eine sehr kleine, aber sehr riskante Gruppe bildet.
SELECT
    COUNT(*) AS anzahl_kern_hohes_risiko,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE loan_percent_income > 0.50
  AND loan_int_rate >= 15;


-- Hier erweitern wir die Hochrisiko-Idee etwas.
-- Statt nur einer festen Zweier-Kombination genuegt jetzt jede Kombination aus zwei der drei starken Faktoren:
-- hohe Kreditquote, hoher Zinssatz und frueherer Default.
-- So wird die Hochrisiko-Gruppe groesser, bleibt aber fachlich klar begruendbar.
SELECT
    COUNT(*) AS anzahl_erweitertes_hohes_risiko,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE (loan_percent_income > 0.50 AND loan_int_rate >= 15)
   OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
   OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y');


-- Diese Abfrage fasst die erweiterte Hochrisiko-Gruppe sauber zusammen.
-- Wir berechnen nicht nur die Anzahl, sondern auch den Anteil am Gesamtdatensatz und die Ausfallquote.
-- So koennen wir spaeter begruenden, ob die hohe Risikogruppe klein genug und gleichzeitig riskant genug ist.
SELECT
    COUNT(*) AS anzahl_hohes_risiko,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE (loan_percent_income > 0.50 AND loan_int_rate >= 15)
   OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
   OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y');


-- Jetzt bauen wir einen ersten Kern fuer 'Niedriges Risiko'.
-- Die Logik ist hier bewusst die sichere Gegenrichtung:
-- kein frueherer Default, Kreditquote hoechstens 20 Prozent und Zinssatz unter 10 Prozent.
-- So suchen wir eine Gruppe, die gross genug und gleichzeitig klar ausfallarm ist.
SELECT
    COUNT(*) AS anzahl_niedriges_risiko_kern,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE cb_person_default_on_file = 'N'
  AND loan_percent_income <= 0.20
  AND loan_int_rate < 10;


-- Hier testen wir zum ersten Mal eine komplette 3er-Einteilung mit CASE WHEN.
-- Zuerst wird 'Hohes Risiko' geprueft, dann 'Niedriges Risiko', und alles dazwischen landet automatisch in 'Mittleres Risiko'.
-- Die Reihenfolge ist wichtig, weil CASE immer die erste passende Bedingung nimmt.
-- Mit COUNT und AVG vergleichen wir Groesse und Ausfallquote aller drei Gruppen.
SELECT
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY risiko_gruppe
ORDER BY anteil_prozent DESC;


-- Diese Abfrage verknuepft alte Loan Grades mit unserer neuen Risikologik.
-- So sehen wir, wie viele Faelle pro altem Grade in niedrig, mittel oder hoch landen.
-- Das ist wichtig, um spaeter Uebereinstimmungen und Widersprueche zwischen altem und neuem Modell zu beschreiben.
SELECT
    loan_grade,
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe,
    COUNT(*) AS anzahl_faelle
FROM credit_risk
GROUP BY loan_grade, risiko_gruppe
ORDER BY loan_grade, risiko_gruppe;


-- Jetzt holen wir uns gezielt Widerspruchsfaelle heraus.
-- Teil 1 sucht D oder E, die nach der aktuellen Logik eher niedrig erscheinen.
-- Teil 2 sucht C-Faelle, die nach unserer neuen Logik schon hochriskant wirken.
-- So bekommen wir konkrete Beispiele fuer moegliche Fehlbewertungen oder fuer Grenzfaelle der Logik.
SELECT *
FROM credit_risk
WHERE (loan_grade IN ('D', 'E') AND cb_person_default_on_file = 'N' AND loan_percent_income <= 0.20 AND loan_int_rate < 10)
   OR (loan_grade = 'C' AND (
          (loan_percent_income > 0.50 AND loan_int_rate >= 15)
       OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
       OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
   ))
ORDER BY loan_grade, loan_percent_income DESC, loan_int_rate DESC;


-- Hier machen wir die Niedrigrisiko-Definition strenger.
-- Zusatzbedingung ist jetzt eine Beschaeftigungsdauer ueber 1 Jahr.
-- Damit soll die niedrige Gruppe etwas kleiner, aber stabiler und sauberer werden.
SELECT
    COUNT(*) AS anzahl_niedriges_risiko_strenger,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE cb_person_default_on_file = 'N'
  AND loan_percent_income <= 0.20
  AND loan_int_rate < 10
  AND person_emp_length > 1;


-- Jetzt testen wir erneut die komplette 3er-Verteilung mit der strengeren Niedrigrisiko-Regel.
-- So pruefen wir, ob die mittlere Gruppe weiterhin sinnvoll dazwischen liegt und ob die neue Trennung insgesamt stabiler wirkt.
SELECT
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
          AND person_emp_length > 1
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY risiko_gruppe
ORDER BY anteil_prozent DESC;


-- Diese Abfrage wiederholt den Vergleich alte Grades gegen neue Risikogruppen, diesmal mit der strengeren Niedrigrisiko-Regel.
-- So sehen wir, ob problematische D/E-Faelle in 'Niedriges Risiko' dadurch weniger werden.
SELECT
    loan_grade,
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
          AND person_emp_length > 1
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe,
    COUNT(*) AS anzahl_faelle
FROM credit_risk
GROUP BY loan_grade, risiko_gruppe
ORDER BY loan_grade, risiko_gruppe;


-- Hier schauen wir uns die wenigen verbliebenen D/E-Faelle an, die trotz strengerer Logik noch als niedrig eingestuft werden.
-- Das hilft zu entscheiden, ob die Niedrigrisiko-Regel noch einen weiteren Sicherheitsfilter braucht.
SELECT *
FROM credit_risk
WHERE loan_grade IN ('D', 'E')
  AND cb_person_default_on_file = 'N'
  AND loan_percent_income <= 0.20
  AND loan_int_rate < 10
  AND person_emp_length > 1
ORDER BY loan_grade, loan_percent_income DESC;


-- Jetzt testen wir einen zusaetzlichen Wohnfilter fuer Niedrigrisiko.
-- Nur OWN und MORTGAGE werden noch zugelassen.
-- Die Idee dahinter ist: Die Gruppe soll noch sauberer werden, auch wenn sie dadurch kleiner wird.
SELECT
    COUNT(*) AS anzahl_niedriges_risiko_wohnfilter,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
WHERE cb_person_default_on_file = 'N'
  AND loan_percent_income <= 0.20
  AND loan_int_rate < 10
  AND person_emp_length > 1
  AND person_home_ownership IN ('OWN', 'MORTGAGE');


-- Diese Abfrage testet erneut die komplette 3er-Verteilung, diesmal mit dem Wohnfilter in 'Niedriges Risiko'.
-- So sehen wir, ob die Ausfallquote im Niedrigrisiko-Bereich sinkt und ob die Gruppe eventuell zu klein wird.
SELECT
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
          AND person_emp_length > 1
          AND person_home_ownership IN ('OWN', 'MORTGAGE')
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY risiko_gruppe
ORDER BY anteil_prozent DESC;



-- ============================================================
-- TEIL F - FALLBEISPIELE FUER KREDITE, DIE WAHRSCHEINLICH
--          NICHT HAETTEN VERGEBEN WERDEN DUERFEN
-- ============================================================

-- Diese Abfrage sucht gezielt nach besonders problematischen Einzelfaellen.
-- Laut Aufgabenstellung sollen nicht nur allgemeine Auffaelligkeiten,
-- sondern auch konkrete Kredite gezeigt werden, die wahrscheinlich nie
-- haetten vergeben werden duerfen.
-- Deshalb suchen wir hier nach harten Kombinationen aus mehreren Warnsignalen,
-- zum Beispiel:
-- - sehr hohe Kreditquote,
-- - sehr niedriges Einkommen bei vergleichsweise hohem Kredit,
-- - frueherer Default,
-- - hoher Zinssatz,
-- - und tatsaechlicher Ausfall.
-- Die Sortierung bringt die drastischsten Faelle nach oben, damit spaeter
-- gute Fallbeispiele fuer die Praesentation ausgewaehlt werden koennen.
SELECT *
FROM credit_risk
WHERE (
        loan_percent_income > 0.50
        AND loan_status = 1
      )
   OR (
        cb_person_default_on_file = 'Y'
        AND loan_percent_income > 0.50
      )
   OR (
        loan_int_rate >= 15
        AND loan_percent_income > 0.50
      )
   OR (
        person_income < 20000
        AND loan_amnt > 10000
      )
ORDER BY loan_percent_income DESC, person_income ASC, loan_int_rate DESC
LIMIT 15;


-- Diese zweite Abfrage zeigt dieselbe Idee noch einmal fokussierter fuer die
-- spaetere muendliche Erklaerung.
-- Hier holen wir nur die Faelle, in denen ein Kreditbetrag von mehr als 10.000
-- auf ein Einkommen unter 20.000 trifft ODER die Kreditquote ueber 60 Prozent
-- liegt. Das sind besonders leicht erklaerbare Negativbeispiele fuer die
-- Praesentation, weil die finanzielle Ueberlastung sofort sichtbar wird.
SELECT *
FROM credit_risk
WHERE (person_income < 20000 AND loan_amnt > 10000)
   OR loan_percent_income >= 0.60
ORDER BY loan_percent_income DESC, person_income ASC
LIMIT 10;


-- ============================================================
-- TEIL G - FALLBEISPIELE FUER MOEGLICHERWEISE FALSCH VERGEBENE
--          LOAN GRADES
-- ============================================================

-- In diesem Teil suchen wir nicht nur Durchschnittswerte pro Loan Grade,
-- sondern konkrete Einzelfaelle.
-- Die Aufgabenstellung verlangt ausdruecklich auch Hinweise auf moeglichweise
-- falsch vergebene Loan Grades.
-- Darum schauen wir in zwei Richtungen:
-- 1. Zu gut bewertete Faelle: gute alte Grades A/B trotz starker Warnsignale.
-- 2. Zu streng bewertete Faelle: schlechte alte Grades D/E/F/G trotz eher
--    stabiler Merkmale.

-- TEIL G1: MOEGLICHERWEISE ZU GUT VERGEBENE LOAN GRADES
-- Diese Abfrage sucht nach alten guten Grades A oder B, obwohl gleichzeitig
-- deutliche Warnsignale vorliegen.
-- Das koennen Hinweise darauf sein, dass ein Kredit zu positiv bewertet wurde.
-- Wir schauen hier besonders auf:
-- - hohe Kreditquote,
-- - fruehere Defaults,
-- - hohe Zinssaetze,
-- - und tatsaechlichen Ausfall.
SELECT *
FROM credit_risk
WHERE loan_grade IN ('A', 'B')
  AND (
        (loan_percent_income > 0.50 AND loan_status = 1)
     OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
     OR (loan_int_rate >= 15 AND loan_status = 1)
     OR (cb_person_default_on_file = 'Y' AND loan_status = 1)
      )
ORDER BY loan_grade, loan_percent_income DESC, loan_int_rate DESC
LIMIT 15;


-- TEIL G2: MOEGLICHERWEISE ZU STRENG VERGEBENE LOAN GRADES
-- Hier suchen wir die Gegenrichtung:
-- alte schlechte Grades D, E, F oder G, obwohl die Faelle nach unseren
-- Stabilitaetskriterien eher unauffaellig wirken.
-- Solche Faelle koennen darauf hindeuten, dass das alte System vereinzelt
-- zu streng bewertet hat.
SELECT *
FROM credit_risk
WHERE loan_grade IN ('D', 'E', 'F', 'G')
  AND cb_person_default_on_file = 'N'
  AND loan_percent_income <= 0.20
  AND loan_int_rate < 10
  AND person_emp_length > 1
ORDER BY loan_grade, loan_percent_income DESC, loan_int_rate ASC
LIMIT 15;


-- ============================================================
-- TEIL H - OPTIONALE VERGLEICHSVARIANTE:
--          LOAN GRADE ALS ZUSAETZLICHER FAKTOR IN DER
--          RISIKOLOGIK
-- ============================================================

-- Diese Abfrage ist bewusst als optionale Vergleichsvariante gedacht.
-- Unser bisheriges Hauptmodell wurde absichtlich moeglichst unabhaengig von
-- den alten Loan Grades aufgebaut.
-- Da die alten Grades aber ebenfalls klare Informationen zur Ausfallquote
-- geliefert haben, testen wir hier zusaetzlich eine alternative Version,
-- in der sehr schlechte alte Grades F/G direkt als 'Hohes Risiko' und gute
-- alte Grades A/B nur unter stabilen Bedingungen als 'Niedriges Risiko'
-- mitberuecksichtigt werden.
-- Ziel ist nicht automatisch, das Hauptmodell zu ersetzen, sondern zu pruefen,
-- ob sich dadurch die Verteilung verbessert oder die mittlere Gruppe kleiner
-- und gleichzeitig plausibel bleibt.
SELECT
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
          OR loan_grade IN ('F', 'G')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
          AND person_emp_length > 1
          AND loan_grade IN ('A', 'B')
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe_mit_grade,
    COUNT(*) AS anzahl_faelle,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY risiko_gruppe_mit_grade
ORDER BY anteil_prozent DESC;


-- Diese Zusatzabfrage macht die optionale Grade-Variante direkt mit dem
-- bisherigen Hauptmodell vergleichbar.
-- So kann spaeter in der Praesentation oder im Gespraech mit dem Lehrer ruhig
-- erklaert werden, dass ein Modell ohne loan_grade das Hauptmodell bleibt,
-- waehrend die Variante mit loan_grade als Zusatztest betrachtet wurde.
SELECT
    'Hauptmodell ohne loan_grade' AS modell,
    risiko_gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM risiko_modell_v1), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM risiko_modell_v1
GROUP BY risiko_gruppe

UNION ALL

SELECT
    'Vergleichsmodell mit loan_grade' AS modell,
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
          OR loan_grade IN ('F', 'G')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
          AND person_emp_length > 1
          AND loan_grade IN ('A', 'B')
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM credit_risk
GROUP BY risiko_gruppe;


-- ============================================================
-- FINALES MODELL ALS VIEW UND BEISPIELFAELLE
-- ============================================================

-- ABSCHNITT 2: FESTE MODELLVERSION ALS VIEW
-- Mit CREATE OR REPLACE VIEW speichern wir unsere aktuell beste Hauptlogik unter einem Namen ab.
-- Die View verhaelt sich danach fast wie eine Tabelle, enthaelt aber zusaetzlich die neue Spalte risiko_gruppe.
-- Das macht alle spaeteren Auswertungen einfacher, weil wir die CASE-Logik nicht dauernd neu schreiben muessen.
CREATE OR REPLACE VIEW risiko_modell_v1 AS
SELECT
    *,
    CASE
        WHEN (loan_percent_income > 0.50 AND loan_int_rate >= 15)
          OR (loan_percent_income > 0.50 AND cb_person_default_on_file = 'Y')
          OR (loan_int_rate >= 15 AND cb_person_default_on_file = 'Y')
        THEN 'Hohes Risiko'

        WHEN cb_person_default_on_file = 'N'
          AND loan_percent_income <= 0.20
          AND loan_int_rate < 10
          AND person_emp_length > 1
        THEN 'Niedriges Risiko'

        ELSE 'Mittleres Risiko'
    END AS risiko_gruppe
FROM credit_risk;


-- Diese kurze Kontrollabfrage prueft, ob die View korrekt erstellt wurde.
-- Wir zaehlen nur, wie viele Faelle in jeder neuen Risikogruppe liegen.
SELECT risiko_gruppe, COUNT(*) AS anzahl_faelle
FROM risiko_modell_v1
GROUP BY risiko_gruppe;


-- Hier holen wir die finale Kennzahlen-Uebersicht aus der View.
-- Wir sehen pro Risikogruppe die Anzahl, den Anteil am Gesamtdatensatz und die Ausfallquote.
-- Das ist eine zentrale Ergebnis-Tabelle fuer Skript und Praesentation.
SELECT
    risiko_gruppe,
    COUNT(*) AS anzahl_faelle,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM risiko_modell_v1), 2) AS anteil_prozent,
    ROUND(AVG(loan_status) * 100, 2) AS ausfallquote_prozent
FROM risiko_modell_v1
GROUP BY risiko_gruppe;


-- Jetzt holen wir 5 konkrete Beispielzeilen aus der Gruppe 'Hohes Risiko'.
-- Solche Beispiele helfen spaeter, das Modell nicht nur mit Zahlen, sondern auch mit typischen Faellen zu erklaeren.
SELECT *
FROM risiko_modell_v1
WHERE risiko_gruppe = 'Hohes Risiko'
LIMIT 5;


-- Hier holen wir 5 Beispielzeilen aus 'Niedriges Risiko'.
-- So koennen wir spaeter zeigen, wie typische eher unauffaellige Faelle im Datensatz aussehen.
SELECT *
FROM risiko_modell_v1
WHERE risiko_gruppe = 'Niedriges Risiko'
LIMIT 5;


-- Diese Abfrage zeigt 5 Beispielzeilen aus 'Mittleres Risiko'.
-- Die mittlere Gruppe ist wichtig, weil sie weder klar harmlos noch klar extrem riskant ist.
-- Mit solchen Beispielen kann man in der Praesentation gut erklaeren, warum nicht jeder Fall eindeutig niedrig oder hoch ist.
SELECT *
FROM risiko_modell_v1
WHERE risiko_gruppe = 'Mittleres Risiko'
LIMIT 5;


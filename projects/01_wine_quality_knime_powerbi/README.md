# Wine Quality Classification – KNIME + Power BI

## Ziel

Ziel des Projekts war es, Rotwein- und Weißweindaten zu bereinigen, chemische Merkmale zu analysieren und die Weinqualität in die Klassen **low**, **medium** und **high** zu klassifizieren.

## Tools

- KNIME
- Power BI
- Excel
- Decision Tree
- Random Forest
- Cross Validation

## Vorgehen

1. Zusammenführung von Rotwein- und Weißweindaten
2. Datenbereinigung und Prüfung der Datenqualität
3. Bildung der Zielvariable `quality_category`
4. Vermeidung von Data Leakage durch Ausschluss der ursprünglichen `quality`-Spalte
5. Explorative Analyse chemischer Merkmale
6. Training und Bewertung von Decision Tree und Random Forest
7. Visualisierung der Ergebnisse in Power BI

## Ergebnis

Das Projekt zeigt einen vollständigen Data-Analytics-Prozess von Datenimport über Bereinigung und Modellbewertung bis zur Ergebnisvisualisierung. Besonders stark ist die Verbindung aus KNIME-Workflow, Machine-Learning-Logik und Power-BI-Reporting.

## Wichtige Kennzahlen

- 5.320 bereinigte Weine
- 14 Analyse-Spalten
- 3 Qualitätsklassen
- Random Forest als bestes Modell

## Ordnerstruktur

- `data/` – Rohdaten und bereinigte Daten
- `knime/` – KNIME Workflow Export
- `powerbi/` – Power-BI-Dashboard
- `docs/` – Projektdokumentation
- `images/` – Screenshots

## Recruiter-Zusammenfassung

Eine natürlich formulierte Projektzusammenfassung liegt unter:

`docs/project_summary_for_recruiters.md`

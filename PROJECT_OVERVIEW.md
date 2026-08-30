# Project Overview

Diese Übersicht fasst meine aktuell veröffentlichten Data-Analytics-Projekte kompakt zusammen.

## 1. Crypto Entry Intelligence

**Fokus:** End-to-End Data Analytics, Datenqualität, Backtesting und Out-of-Sample-Validierung  
**Tools:** Python, SQL, SQLite, Power BI

Historische BTC-, ETH- und SOL-Daten wurden über eine reproduzierbare Pipeline verarbeitet, auf Qualität geprüft, in SQL strukturiert und mit fünf transparenten Einstiegssignalen analysiert. Handelskosten, zeitliche Trennung und ein einmaliger finaler Test wurden ausdrücklich berücksichtigt.

**Ausgewählte Ergebnisse:** 30 Signal-Horizont-Kombinationen · 0/30 über Development, Validation und Final Test stabil netto positiv · finaler Durchschnitt bei 30 bp: -0,2853 % auf 1h und -0,2669 % auf 4h

[Projekt öffnen](https://github.com/aminzamenali-maker/crypto-entry-intelligence)

---

## 2. Olist E-Commerce Performance Analysis

**Fokus:** Business Intelligence, KPI Reporting und Customer Experience  
**Tools:** Power BI, Power Query, DAX-Grundlagen, Datenmodellierung

Mehrere E-Commerce-Datentabellen wurden aufbereitet und in einen mehrseitigen Management-Report überführt. Analysiert werden unter anderem Umsatz, Bestellungen, Lieferperformance, Bewertungen und Produktperformance.

**Ausgewählte KPIs:** 13,53 Mio. Revenue · 98 Tsd. Orders · 92 % On-Time Delivery · 4,03 Average Review Score

[Projekt öffnen](projects/02_olist_ecommerce_powerbi/)

---

## 3. Wine Quality Classification

**Fokus:** End-to-End Analytics und Klassifikation  
**Tools:** KNIME, Power BI, Random Forest, Decision Tree, Cross Validation

Rotwein- und Weißweindaten wurden bereinigt, chemische Merkmale analysiert und die Weinqualität in drei Klassen klassifiziert. Die Ergebnisse wurden anschließend in Power BI visualisiert.

**Ausgewählte Ergebnisse:** 5.320 bereinigte Weine · 14 Analyse-Spalten · 3 Qualitätsklassen · Random Forest als bestes Vergleichsmodell

[Projekt öffnen](projects/01_wine_quality_knime_powerbi/)

---

## 4. Credit Risk SQL Analysis

**Fokus:** Datenqualität, SQL-Analyse und transparente Risikologik  
**Tools:** SQL, CASE WHEN, Aggregationen, Views

Kreditdaten wurden auf Qualität und Risikofaktoren untersucht. Darauf aufbauend entstand eine regelbasierte Einteilung in niedrige, mittlere und hohe Risikogruppen sowie eine wiederverwendbare finale SQL-View.

**Ausgewählte Ergebnisse:** 3 Risikogruppen · 58,06 % Ausfallquote in der hohen Risikogruppe · finale View `risiko_modell_v1`

[Projekt öffnen](projects/03_credit_risk_sql_analysis/)

---

## 5. Spotify 2023 Python EDA

**Fokus:** Explorative Datenanalyse und Feature Engineering  
**Tools:** Python, Pandas, Matplotlib

Spotify-Songdaten wurden bereinigt, um neue Merkmale ergänzt und auf Zusammenhänge mit hohen Streaming-Zahlen untersucht. Visualisierungen und Korrelationsanalysen unterstützen die Interpretation.

**Ausgewählte Ergebnisse:** 952 Songs · 35 Spalten · etwa 0,79 Korrelation zwischen Playlist-Präsenz und Streams

[Projekt öffnen](projects/04_spotify_2023_python_eda/)

---

## 6. Sales Performance Dashboard

**Fokus:** Excel Reporting und Sales Analytics  
**Tools:** Excel, Power Query, Pivot-Tabellen, Dashboarding

Verkaufsdaten wurden bereinigt, mit Pivot-Tabellen ausgewertet und in einem interaktiven KPI-Dashboard dargestellt. Im Mittelpunkt stehen Umsatz, Gewinn, Kosten, Marge sowie Produkt- und Regionalperformance.

**Ausgewählte KPIs:** 85,27 Mio. EUR Umsatz · 32,22 Mio. EUR Gewinn · 47 % Marge · Zeitraum 2011–2016

[Projekt öffnen](projects/05_sales_dashboard_excel/)

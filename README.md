{\rtf1\ansi\ansicpg1252\cocoartf2868
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Cities Data Engineering Project\
\
## Overview\
This project uses Python, Jupyter Notebooks, and MySQL to collect, clean, and organize city-related data into a structured relational database.\
\
The database includes:\
- city information\
- coordinates\
- population\
- sunrise and sunset data\
- weather forecasts\
- airport and flight data\
\
## Project Goal\
The goal of this project was to build a clean final SQL database design from multiple Python data collection pipelines and organize the data for efficient querying and analysis.\
\
## Tech Stack\
- Python\
- Jupyter Notebook\
- MySQL\
- MySQL Workbench\
- SQL\
- Web scraping\
- APIs\
\
## Databases\
### `cities_db`\
This is the original/source database containing the raw imported tables.\
\
### `cities_final`\
This is the cleaned and normalized final database used for analysis.\
\
## Final Tables\
The final database includes:\
- `cities`\
- `city_population`\
- `city_days`\
- `city_weather`\
- `airports`\
- `city_airports`\
- `flights`\
\
## Project Workflow\
1. Collected city-related data using Python notebooks\
2. Loaded raw data into `cities_db`\
3. Created a cleaned schema in `cities_final`\
4. Migrated and cleaned the data\
5. Queried the final database for analysis\
\
## Example Query\
```sql\
SELECT c.city_name, w.forecast_datetime, w.temperature_c\
FROM city_weather w\
JOIN cities c\
ON w.city_id = c.city_id\
LIMIT 10;}
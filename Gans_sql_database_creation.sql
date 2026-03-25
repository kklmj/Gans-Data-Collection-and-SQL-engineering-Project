-- Step 1 create cities_final

CREATE DATABASE cities_final;
USE cities_final;


-- Step 2 Create the final tables in cities_final

CREATE TABLE cities (
    city_id BIGINT PRIMARY KEY,
    city_name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    latitude DOUBLE,
    longitude DOUBLE
);

CREATE TABLE city_population (
    city_id BIGINT PRIMARY KEY,
    population BIGINT,
    CONSTRAINT fk_population_city
        FOREIGN KEY (city_id) REFERENCES cities(city_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE city_days (
    city_id BIGINT PRIMARY KEY,
    sunrise VARCHAR(100),
    sunset VARCHAR(100),
    CONSTRAINT fk_days_city
        FOREIGN KEY (city_id) REFERENCES cities(city_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE city_weather (
    weather_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    city_id BIGINT NOT NULL,
    forecast_datetime DATETIME NOT NULL,
    temperature_c DOUBLE,
    feels_like_c DOUBLE,
    weather_description VARCHAR(255),
    pop DOUBLE,
    rain_3h_mm DOUBLE,
    wind_speed DOUBLE,
    CONSTRAINT fk_weather_city
        FOREIGN KEY (city_id) REFERENCES cities(city_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_weather_city_time (city_id, forecast_datetime)
);

CREATE TABLE airports (
    airport_iata VARCHAR(10) PRIMARY KEY
);

CREATE TABLE city_airports (
    city_id BIGINT NOT NULL,
    airport_iata VARCHAR(10) NOT NULL,
    PRIMARY KEY (city_id, airport_iata),
    CONSTRAINT fk_city_airports_city
        FOREIGN KEY (city_id) REFERENCES cities(city_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_city_airports_airport
        FOREIGN KEY (airport_iata) REFERENCES airports(airport_iata)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE flights (
    flight_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    city_id BIGINT NOT NULL,
    airport_iata VARCHAR(10),
    flight_number VARCHAR(50),
    airline_name VARCHAR(255),
    departure_airport VARCHAR(255),
    arrival_scheduled_time_local VARCHAR(100),
    arrival_terminal VARCHAR(50),
    arrival_gate VARCHAR(50),
    status VARCHAR(100),
    CONSTRAINT fk_flights_city
        FOREIGN KEY (city_id) REFERENCES cities(city_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_flights_airport
        FOREIGN KEY (airport_iata) REFERENCES airports(airport_iata)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);


-- Step 3 Migrate the data from cities_db into cities_final
USE cities_final;

-- 1. cities
INSERT INTO cities (city_id, city_name, country, latitude, longitude)
SELECT DISTINCT
    c.city_id,
    c.city,
    c.country,
    cc.latitude,
    cc.longitude
FROM cities_db.cities c
LEFT JOIN cities_db.city_coordinates cc
    ON c.city_id = cc.city_id;

-- 2. population
INSERT INTO city_population (city_id, population)
SELECT
    city_id,
    MAX(CAST(REPLACE(REPLACE(TRIM(population), ',', ''), ' ', '') AS UNSIGNED)) AS population
FROM cities_db.city_population
WHERE population IS NOT NULL
  AND TRIM(population) <> ''
  AND REPLACE(REPLACE(TRIM(population), ',', ''), ' ', '') REGEXP '^[0-9]+$'
GROUP BY city_id;

-- 3. day data
INSERT INTO city_days (city_id, sunrise, sunset)
SELECT DISTINCT
    city_id,
    sunrise,
    sunset
FROM cities_db.city_days;

-- 4. weather
INSERT INTO city_weather (
    city_id,
    forecast_datetime,
    temperature_c,
    feels_like_c,
    weather_description,
    pop,
    rain_3h_mm,
    wind_speed
)
SELECT
    city_id,
    forecast_datetime,
    temperature_c,
    feels_like_c,
    weather_description,
    pop,
    rain_3h_mm,
    wind_speed
FROM cities_db.city_weather;

-- 5. airports
INSERT INTO airports (airport_iata)
SELECT DISTINCT airport_iata
FROM cities_db.city_flights
WHERE airport_iata IS NOT NULL
  AND TRIM(airport_iata) <> '';

-- 6. city-airport links
INSERT INTO city_airports (city_id, airport_iata)
SELECT DISTINCT
    city_id,
    airport_iata
FROM cities_db.city_flights
WHERE airport_iata IS NOT NULL
  AND TRIM(airport_iata) <> '';

-- 7. flights
INSERT INTO flights (
    city_id,
    airport_iata,
    flight_number,
    airline_name,
    departure_airport,
    arrival_scheduled_time_local,
    arrival_terminal,
    arrival_gate,
    status
)
SELECT
    city_id,
    airport_iata,
    flight_number,
    airline_name,
    departure_airport,
    arrival_scheduled_time_local,
    arrival_terminal,
    arrival_gate,
    status
FROM cities_db.city_flights;

-- Step 4Check that the migration worked
SELECT COUNT(*) AS cities_count FROM cities_final.cities;
SELECT COUNT(*) AS population_count FROM cities_final.city_population;
SELECT COUNT(*) AS days_count FROM cities_final.city_days;
SELECT COUNT(*) AS weather_count FROM cities_final.city_weather;
SELECT COUNT(*) AS airports_count FROM cities_final.airports;
SELECT COUNT(*) AS city_airports_count FROM cities_final.city_airports;
SELECT COUNT(*) AS flights_count FROM cities_final.flights;

-- Step 5 Test a few queries
SELECT * FROM cities_final.cities LIMIT 5;

SELECT c.city_name, w.forecast_datetime, w.temperature_c
FROM cities_final.city_weather w
JOIN cities_final.cities c
ON w.city_id = c.city_id
LIMIT 10;

SELECT c.city_name, f.flight_number, f.airline_name, f.status
FROM cities_final.flights f
JOIN cities_final.cities c
ON f.city_id = c.city_id
LIMIT 10;
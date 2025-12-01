import requests
import pandas as pd
import pymysql
from datetime import datetime
from prefect import flow, task, get_run_logger

# --- CONFIGURATION ---
API_KEY = "4ff7abb2cd202badcf303f6264c2325e" 
DB_CONFIG = {
    "host": "localhost",
    "user": "root", 
    "password": "AZ71957004am$", 
    "db": "weather_db",
    "charset": "utf8mb4",
    "cursorclass": pymysql.cursors.DictCursor
}

# --- TASK 1: EXTRACT ---
@task(name="Extract Weather Data", retries=3)
def extract_task(city="Muscat"):
    logger = get_run_logger()
    url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}"
    
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        # Extract specific fields [cite: 24]
        extracted_data = {
            "timestamp": datetime.now(),
            "temp_kelvin": data["main"]["temp"],
            "humidity": data["main"]["humidity"],
            "condition": data["weather"][0]["main"]
        }
        logger.info(f"Extracted data for {city}")
        return extracted_data
    except Exception as e:
        logger.error(f"Extraction failed: {e}")
        return None

# --- TASK 2: TRANSFORM ---
@task(name="Transform Weather Data")
def transform_task(data):
    logger = get_run_logger()
    if not data:
        return None

    # Challenge: Data Quality Checker [cite: 59]
    if data['temp_kelvin'] is None or data['humidity'] is None:
        logger.warning("Data Quality Issue: Missing values detected.")
        # Handle missing values [cite: 36]
        return None 

    # Convert Kelvin to Celsius [cite: 35]
    temp_c = round(data["temp_kelvin"] - 273.15, 2)
    humidity = data["humidity"]
    
    # Challenge: Alerting [cite: 60]
    if temp_c > 50:
        logger.warning(f"ALERT: High Temperature detected: {temp_c}°C")
    if humidity > 90:
        logger.warning(f"ALERT: High Humidity detected: {humidity}%")

    # Add computed column FeelsLike [cite: 38]
    # Formula given: temperature - humidity * 0.1
    feels_like = round(temp_c - (humidity * 0.1), 2)

    transformed_row = {
        "timestamp": data["timestamp"],
        "temperature": temp_c,
        "humidity": humidity,
        "weather_condition": data["condition"],
        "feels_like": feels_like
    }
    
    logger.info("Transformation complete.")
    return transformed_row

# --- TASK 3: LOAD ---
@task(name="Load to MySQL")
def load_task(row):
    logger = get_run_logger()
    if not row:
        logger.info("No data to load.")
        return

    connection = pymysql.connect(**DB_CONFIG)
    try:
        with connection.cursor() as cursor:
            # Use REPLACE INTO to handle duplicates 
            sql = """
            REPLACE INTO hourly_weather 
            (timestamp, temperature, humidity, weather_condition, feels_like)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (
                row["timestamp"], 
                row["temperature"], 
                row["humidity"], 
                row["weather_condition"], 
                row["feels_like"]
            ))
        connection.commit()
        logger.info("Data loaded to MySQL successfully.")
    except Exception as e:
        logger.error(f"Database load failed: {e}")
    finally:
        connection.close()

# --- THE FLOW ---
@flow(name="Hourly Weather ETL")
def weather_etl_flow():
    # Orchestrate the tasks [cite: 48]
    raw_data = extract_task()
    clean_data = transform_task(raw_data)
    load_task(clean_data)

if __name__ == "__main__":
    weather_etl_flow()
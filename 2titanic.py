import pandas as pd
import numpy as np
import pymysql
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OrdinalEncoder
from sklearn.compose import ColumnTransformer

# --- Configuration ---
# YOU MUST REPLACE 'your_mysql_user' and 'your_mysql_password' with your actual credentials!
DB_HOST = 'localhost'
DB_USER = 'root' 
DB_PASSWORD = 'AZ71957004am$'
DATABASE_NAME = 'titanic_2db'
TABLE_NAME = 'titanic_2clean'
# File path using a raw string to correctly handle Windows backslashes
FILE_PATH = r'C:\Users\USER PC\Desktop\project\train.csv' 

# --- 1. EXTRACT Stage ---
def extract_data(file_path):
    """Loads the dataset from the CSV file."""
    try:
        df = pd.read_csv(file_path)
        print(f"EXTRACT: Dataset loaded successfully from {file_path}. Total rows: {len(df)}")
        return df
    except FileNotFoundError:
        print(f"ERROR: {file_path} not found. Please ensure it is in the specified location.")
        exit()
    except Exception as e:
        print(f"ERROR during extraction: {e}")
        exit()

# --- 2. TRANSFORM Stage (Using scikit-learn Pipelines) ---
def transform_data(df):
    """Cleans, transforms, and prepares the data for loading."""
    
    # A. Select the required columns using the confirmed name 'Sex'
    df_selected = df[['PassengerId', 'Survived', 'Pclass', 'Sex', 'Age', 'Fare', 'Embarked']].copy()

    numeric_features = ['Age', 'Fare']
    categorical_features = ['Sex', 'Embarked'] 
    passthrough_features = ['PassengerId', 'Survived', 'Pclass']

    # B, D: Numeric Pipeline (Impute median, Scale with StandardScaler)
    numeric_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler())
    ])

    # B, C: Categorical Pipeline (Impute most frequent, Encode with OrdinalEncoder for DB load)
    # OrdinalEncoder is used to meet the INT requirement (Sex: 0/1, Embarked: 0/1/2)
    categorical_transformer = Pipeline(steps=[
        ('imputer', SimpleImputer(strategy='most_frequent')),
        ('label_encoder', OrdinalEncoder(handle_unknown='use_encoded_value', unknown_value=-1))
    ])

    # Column Transformer to apply different transformations to different columns
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', numeric_transformer, numeric_features),
            ('cat', categorical_transformer, categorical_features),
            ('pass', 'passthrough', passthrough_features)
        ],
        remainder='drop'
    )

    # Apply the transformations
    df_transformed = preprocessor.fit_transform(df_selected)
    
    # E. Produce final cleaned DataFrame
    new_column_names = numeric_features + categorical_features + passthrough_features 
    df_clean = pd.DataFrame(df_transformed, columns=new_column_names)

    # Reorder the columns to match the desired database schema order
    df_clean = df_clean[[
        'PassengerId', 
        'Survived', 
        'Pclass', 
        'Age', 
        'Fare', 
        'Sex',     
        'Embarked'
    ]].copy()
    
    # Cast necessary columns to INT for database schema compliance
    df_clean['Sex'] = df_clean['Sex'].astype(int)
    df_clean['Embarked'] = df_clean['Embarked'].astype(int)
    df_clean['PassengerId'] = df_clean['PassengerId'].astype(int)
    df_clean['Survived'] = df_clean['Survived'].astype(int)
    df_clean['Pclass'] = df_clean['Pclass'].astype(int)

    print("TRANSFORM: Data cleaning and scaling complete. Ready for load.")
    return df_clean

# --- 3. LOAD Stage (Using PyMySQL) ---
def load_data(df_clean):
    """Connects to MySQL, creates the table, and loads the data."""
    conn = None
    try:
        # A. Connect to MySQL server
        conn = pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD)
        cursor = conn.cursor()

        # Create the database if it doesn't exist and select it
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DATABASE_NAME}")
        conn.select_db(DATABASE_NAME)
        print(f"LOAD: Database '{DATABASE_NAME}' selected.")

        # B. Create the Table 'titanic_clean'
        create_table_query = f"""
        CREATE TABLE IF NOT EXISTS {TABLE_NAME} (
            PassengerId INT PRIMARY KEY,
            Survived INT,
            Pclass INT,
            Age FLOAT,
            Fare FLOAT,
            Sex INT, 
            Embarked INT
        )
        """
        cursor.execute(create_table_query)
        conn.commit()
        print(f"LOAD: Table '{TABLE_NAME}' created/verified.")

        # C. Insert each row into the database
        print(f"LOAD: Inserting {len(df_clean)} rows...")
        insert_query = f"""
        INSERT INTO {TABLE_NAME} (PassengerId, Survived, Pclass, Age, Fare, Sex, Embarked)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE 
            Survived=VALUES(Survived), Pclass=VALUES(Pclass), Age=VALUES(Age), 
            Fare=VALUES(Fare), Sex=VALUES(Sex), Embarked=VALUES(Embarked)
        """
        
        # Prepare data as a list of tuples
        data_to_insert = [tuple(row) for row in df_clean.values]

        # Use executemany for efficient insertion
        cursor.executemany(insert_query, data_to_insert)
        conn.commit()
        print("LOAD: Data loaded successfully.")

        # Verification step
        cursor.execute(f"SELECT * FROM {TABLE_NAME} LIMIT 5")
        results = cursor.fetchall()
        print("\nVerification (First 5 rows from MySQL):")
        for row in results:
            print(row)

    except pymysql.err.OperationalError as e:
        print(f"\nFATAL ERROR: Could not connect to MySQL. Check your credentials (DB_USER/DB_PASSWORD) and ensure MySQL server is running.")
        print(f"MySQL Error Details: {e}")
    except Exception as e:
        print(f"\nERROR during LOAD stage: {e}")
        
    finally:
        if conn and conn.open:
            conn.close()
            print("LOAD: MySQL connection closed.")

# --- Main ETL Execution ---
if __name__ == "__main__":
    
    # 1. EXTRACT
    raw_data = extract_data(FILE_PATH)
    
    # Check if extraction was successful
    if raw_data is not None:
        # 2. TRANSFORM
        clean_data = transform_data(raw_data)
        
        # 3. LOAD
        load_data(clean_data)

    print("\nETL Pipeline completed.")
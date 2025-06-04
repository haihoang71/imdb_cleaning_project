# 🎬 IMDb Data Cleaning Project

This project demonstrates how to clean and normalize raw IMDb movie data using SQL. It includes data preprocessing, type standardization, and restructuring into relational tables for better query performance and data consistency.

---

## 📁 Project Structure
```
imdb-data-cleaning/
├── cleaned_data/
│   ├── imdb_clean.csv          # Cleaned movie data without genre column
│   ├── genre_table.csv         # List of unique genres
│   └── movie_genre.csv         # Mapping between movie IDs and genre IDs
│
├── raw_data/
│   └── imdb_raw.csv            # Original uncleaned dataset
│
├── imdb_cleaning_project.sql   # SQL script for cleaning and transforming the data
├── README.md
```

---

## 🧼 What the Script Does

- Removes duplicates and null values
- Standardizes columns:
  - `release_year`: Converted to `YEAR`
  - `runtime`: Converted to `INT`
  - `gross`: Converted to `DECIMAL` and renamed to `gross(M)`
  - `id`: Add id column
- Adds primary keys and foreign keys
- Separates genres into normalized tables:
  - `genre_table`
  - `movie_genre` (many-to-many relationship)

---

## 📊 Output Tables

- `imdb_clean`: Cleaned movie data
- `genre_table`: Unique genres
- `movie_genre`: Movie-genre relationships

---

## 🗃️ Raw Data

> - Use the raw IMDb dataset from [Kaggle](https://www.kaggle.com/datasets/arthurchongg/imdb-top-1000-movies)

---

## ⚙️ How to Use

1. Load the raw dataset into a MySQL database (`imdb_raw`)
2. Run the script `imdb_cleaning_project.sql` to clean and transform the data
3. Query the `imdb_clean`, `genre_table`, and `movie_genre` tables for analysis

---

## 🧠 Learning Goals

- SQL data cleaning techniques
- Working with `VARCHAR`, `YEAR`, `DECIMAL` conversions
- Splitting multi-value fields into relational structures
- Using stored procedures in MySQL

---

## 📜 License

This project is for educational and demonstration purposes only. No official affiliation with IMDb.


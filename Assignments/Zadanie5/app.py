from flask import Flask, jsonify, request
import sqlite3
import json
import os

app = Flask(__name__)
CONFIG_FILE = "config.json"
DB_FILE = "orders.db"

def init_db():
    with sqlite3.connect(DB_FILE) as conn:
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS orders (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                items TEXT NOT NULL,
                total_price REAL NOT NULL,
                delivery_address TEXT NOT NULL,
                delivery_time TEXT NOT NULL
            )
        """)
        conn.commit()

def load_menu_from_config():
    if not os.path.exists(CONFIG_FILE):
        return []
    with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
        config_data = json.load(f)
        return config_data.get("menu", [])



@app.route('/menu', methods=['GET'])
def get_menu():
    menu = load_menu_from_config()
    return jsonify(menu), 200

@app.route('/save_order', methods=['POST'])
def save_order():
    data = request.json
    if not data or not all(k in data for k in ("items", "total_price", "delivery_address", "delivery_time")):
        print("Received invalid order data:", data)
        return jsonify({"error": "JSON incorrect"}), 400

    try:
        with sqlite3.connect(DB_FILE) as conn:
            cursor = conn.cursor()
            
            cursor.execute("""
                INSERT INTO orders (items, total_price, delivery_address, delivery_time)
                VALUES (?, ?, ?, ?)
            """, (str(data["items"]), data["total_price"], data["delivery_address"], data["delivery_time"]))
            conn.commit()
        return jsonify({"status": "success"}), 201
    except Exception as e:
        print(f"Error saving order: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    init_db()
    app.run(port=5000, debug=True)
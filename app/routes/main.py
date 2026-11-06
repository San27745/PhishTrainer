from flask import Blueprint, jsonify, render_template
from app.db import test_db_connection

main_bp = Blueprint("main", __name__)

@main_bp.get("/")
def home():
    return render_template("index.html")

@main_bp.get("/health")
def health():
    return jsonify({"application": "PhishTrainer", "status": "running"})

@main_bp.get("/health/database")
def database_health():
    result = test_db_connection()
    return jsonify(result), (200 if result["ok"] else 503)

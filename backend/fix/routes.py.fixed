from flask import render_template, Blueprint, jsonify

# Define the functions without creating a new app instance

def index():
    """首页路由，加载Vue应用"""
    return render_template('index.html')

def health():
    """健康检查路由"""
    return jsonify({'status': 'ok', 'version': '1.0.0'})

# These routes will be registered in the main app in __init__.py 
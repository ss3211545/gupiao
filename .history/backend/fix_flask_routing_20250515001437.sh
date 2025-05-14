#!/bin/bash

# 这个脚本修复Flask应用根路径访问问题

# 备份原始文件
cp app/__init__.py app/__init__.py.bak
cp app/routes.py app/routes.py.bak

echo "已备份原始文件为 app/__init__.py.bak 和 app/routes.py.bak"

# 修改routes.py文件
cat > app/routes.py << 'EOL'
from flask import render_template, jsonify

def index():
    """首页路由，加载Vue应用"""
    return render_template('index.html')

def health():
    """健康检查路由"""
    return jsonify({'status': 'ok', 'version': '1.0.0'})
EOL

echo "已更新 routes.py 文件"

# 修改__init__.py文件
cat > app/__init__.py << 'EOL'
from flask import Flask
from flask_socketio import SocketIO
from flask_cors import CORS

socketio = SocketIO()

def create_app():
    app = Flask(__name__, 
                static_folder='../static',
                template_folder='../templates')
    
    app.config['SECRET_KEY'] = 'tailmarket-stock-app-secret-key'
    
    # 允许跨域请求
    CORS(app)
    
    # 注册蓝图
    from app.api import api_bp
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # 导入并注册主路由
    from app.routes import index, health
    
    # 注册路由
    app.route('/')(index)
    app.route('/health')(health)
    
    # 初始化SocketIO
    socketio.init_app(app, cors_allowed_origins="*")
    
    return app
EOL

echo "已更新 __init__.py 文件"
echo "修复完成，请重启应用: python3 run.py" 
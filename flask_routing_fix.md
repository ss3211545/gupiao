# Flask应用根路径404错误修复指南

## 问题描述

当前应用无法访问根路径 ("/")，导致404错误。这是因为路由定义在`app/routes.py`中，但没有被正确注册到Flask应用实例。

## 修复步骤

1. 首先，备份原始文件：

```bash
# 进入应用目录
cd ~/gupiao/backend

# 备份原文件
cp app/__init__.py app/__init__.py.bak
cp app/routes.py app/routes.py.bak
```

2. 更新`routes.py`文件：

```bash
# 创建新的routes.py文件
cat > app/routes.py << 'EOL'
from flask import render_template, jsonify

def index():
    """首页路由，加载Vue应用"""
    return render_template('index.html')

def health():
    """健康检查路由"""
    return jsonify({'status': 'ok', 'version': '1.0.0'})
EOL
```

3. 更新`__init__.py`文件：

```bash
# 创建新的__init__.py文件
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
```

4. 重新启动应用：

```bash
# 重启Flask应用
python3 run.py
```

## 快速修复脚本

如果你想一次性完成所有步骤，可以使用以下脚本：

```bash
#!/bin/bash

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
```

将此脚本复制到服务器，保存为`fix_flask_routing.sh`，然后运行：

```bash
cd ~/gupiao/backend
bash fix_flask_routing.sh
python3 run.py
``` 
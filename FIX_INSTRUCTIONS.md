# 修复Flask应用根路径访问问题

## 问题描述

当前应用无法访问根路径 ("/")，导致404错误。

这是因为虽然在`app/routes.py`中定义了根路径的路由处理函数，但它没有被正确地导入和注册到在`app/__init__.py`中创建的Flask应用实例中。

## 解决方案

需要修改两个关键文件：

1. `app/routes.py` - 将其修改为只导出路由函数，而不是创建新的app实例
2. `app/__init__.py` - 添加代码导入这些路由函数并注册到主应用

## 修复步骤

以下是在服务器上修复此问题的步骤：

### 步骤1: 备份原始文件

```bash
cp app/__init__.py app/__init__.py.bak
cp app/routes.py app/routes.py.bak
```

### 步骤2: 修改routes.py文件

使用以下命令创建新的routes.py文件：

```bash
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

### 步骤3: 修改__init__.py文件

使用以下命令创建新的__init__.py文件：

```bash
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

### 步骤4: 重启应用

修改完成后，重启Flask应用：

```bash
python3 run.py
```

## 问题解释

原来的代码存在两个主要问题：

1. `routes.py`文件中重复创建了Flask应用实例，但这个实例与`run.py`使用的实例不是同一个
2. 根路由('/')定义在了一个没有被实际使用的app实例上

修复后，路由函数被正确注册到在`create_app()`函数中创建的主应用实例上，从而使根路径可以被访问。

## 注意事项

如果修改后出现导入错误，可能需要确保Python解释器能够找到正确的模块路径。如果需要，可以设置PYTHONPATH环境变量：

```bash
export PYTHONPATH=/home/lighthouse/gupiao:$PYTHONPATH
``` 
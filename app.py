from flask import Flask, render_template, request, redirect, url_for, session, jsonify
import pymysql
from werkzeug.security import check_password_hash, generate_password_hash
import os
from functools import wraps
from werkzeug.utils import secure_filename
import time

# 创建Flask应用实例
app = Flask(__name__)
# 设置密钥，用于session加密
app.secret_key = os.urandom(24)

# 数据库连接配置
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '123456',
    'database': 'tutor_system',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

# 创建数据库连接函数
def get_db():
    """
    创建数据库连接
    :return: 数据库连接对象
    """
    try:
        connection = pymysql.connect(**DB_CONFIG)
        return connection
    except Exception as e:
        print(f"数据库连接错误: {e}")
        return None

# 登录验证装饰器
def login_required(f):
    """
    验证用户是否登录的装饰器
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

# 路由：首页
@app.route('/')
def index():
    """
    首页路由
    :return: 渲染首页模板
    """
    return render_template('index.html')

# 路由：登录页面
@app.route('/login', methods=['GET', 'POST'])
def login():
    """
    处理登录功能
    GET请求：显示登录页面
    POST请求：处理用户提交的登录表单
    """
    # 如果是POST请求，说明用户提交了登录表单
    if request.method == 'POST':
        # 从表单中获取用户输入的信息
        username = request.form.get('username')  # 获取用户名
        password = request.form.get('password')  # 获取密码
        user_type = request.form.get('userType')  # 获取用户类型（学生/教师）
        
        # 尝试连接数据库
        conn = get_db()
        # 如果数据库连接失败，返回错误信息
        if not conn:
            return jsonify({
                'status': 'error', 
                'message': '数据库连接失败'
            })
        
        try:
            # 使用数据库连接创建游标
            with conn.cursor() as cursor:
                # 根据用户类型选择要查询的表
                table = 'students' if user_type == 'student' else 'teachers'
                
                # 构建SQL查询语句，查找用户名匹配的用户
                sql = f"SELECT * FROM {table} WHERE username = %s"
                cursor.execute(sql, (username,))
                # 获取查询结果
                user = cursor.fetchone()
                
                # 使用明文密码验证
                if user and user['password'] == password:
                    # 登录成功，在session中保存用户信息
                    session['user_id'] = user['id']  # 保存用户ID
                    session['username'] = user['username']  # 保存用户名
                    session['user_type'] = user_type  # 保存用户类型
                    
                    # 返回成功信息，并指示前端跳转到首页
                    return jsonify({
                        'status': 'success',  # 状态：成功
                        'message': '登录成功',  # 提示消息
                        'redirect': url_for('index')  # 跳转地址：首页
                    })
                else:
                    # 用户名或密码错误，返回错误信息
                    return jsonify({
                        'status': 'error', 
                        'message': '用户名或密码错误'
                    })
                    
        except Exception as e:
            # 如果发生异常，打印错误信息并返回错误提示
            print(f"登录错误: {e}")
            return jsonify({
                'status': 'error', 
                'message': '登录失败，请稍后重试'
            })
            
        finally:
            # 无论成功与否，后都关闭数据库连接
            conn.close()
    
    # 如果是GET请求，显示登录页面
    return render_template('login.html')

# 路由：学生个人中心
@app.route('/student_profile')
@login_required
def student_profile():
    """
    学生个人中心页面
    需要登录才能访问
    """
    if session.get('user_type') != 'student':
        return redirect(url_for('login'))
        
    try:
        # 连接数据库
        conn = get_db()
        if not conn:
            return "数据库连接失败", 500
            
        with conn.cursor() as cursor:
            # 获取学生基本信息
            sql = """
                SELECT id, username, name, grade, phone, email, avatar_url 
                FROM students 
                WHERE id = %s
            """
            cursor.execute(sql, (session.get('user_id'),))
            student = cursor.fetchone()
            
            if not student:
                return redirect(url_for('login'))
            
            # 获取学习记录
            sql = """
                SELECT 
                    lr.*,
                    c.name as course_name,
                    t.name as teacher_name,
                    DATE_FORMAT(lr.date, '%%Y-%%m-%%d') as formatted_date
                FROM learning_records lr
                LEFT JOIN courses c ON lr.course_id = c.id
                LEFT JOIN teachers t ON lr.teacher_id = t.id
                WHERE lr.student_id = %s
                ORDER BY lr.date DESC
            """
            cursor.execute(sql, (session.get('user_id'),))
            learning_records = cursor.fetchall()
            
            # 获取课程安排
            sql = """
                SELECT 
                    s.*,
                    c.name as course_name,
                    t.name as teacher_name,
                    DATE_FORMAT(s.date, '%%Y-%%m-%%d') as formatted_date,
                    TIME_FORMAT(s.time, '%%H:%%i') as formatted_time
                FROM schedules s
                LEFT JOIN courses c ON s.course_id = c.id
                LEFT JOIN teachers t ON s.teacher_id = t.id
                WHERE s.student_id = %s
                AND s.date >= CURDATE()
                ORDER BY s.date, s.time
            """
            cursor.execute(sql, (session.get('user_id'),))
            schedules = cursor.fetchall()
            
            return render_template('student-profile.html',
                                student=student,
                                learning_records=learning_records,
                                schedules=schedules)
            
    except Exception as e:
        print(f"获取学生信息错误: {e}")
        return f"获取信息失败: {str(e)}", 500
        
    finally:
        if conn:
            conn.close()

# 路由：教师个人中心
@app.route('/teacher_profile')
@login_required
def teacher_profile():
    """
    教师个人中心页面
    需要登录才能访问
    """
    # 检查用户类型
    if session.get('user_type') != 'teacher':
        return redirect(url_for('login'))
    
    try:
        # 连接数据库
        conn = get_db()
        if not conn:
            return "数据库连接失败", 500
            
        with conn.cursor() as cursor:
            # 获取教师基本信息
            sql = """
                SELECT t.*, 
                    COALESCE(AVG(r.rating), 5.0) as rating,
                    COUNT(r.id) as rating_count
                FROM teachers t
                LEFT JOIN ratings r ON t.id = r.teacher_id
                WHERE t.id = %s
                GROUP BY t.id
            """
            cursor.execute(sql, (session.get('user_id'),))
            teacher = cursor.fetchone()
            
            if not teacher:
                return redirect(url_for('login'))
            
            # 获取教师证书
            sql = "SELECT * FROM certificates WHERE teacher_id = %s"
            cursor.execute(sql, (session.get('user_id'),))
            certificates = cursor.fetchall()
            
            # 获取教师可用时间
            sql = "SELECT * FROM available_times WHERE teacher_id = %s"
            cursor.execute(sql, (session.get('user_id'),))
            available_times = cursor.fetchall()
            
            # 将证书和可用时间添加到教师信息中
            teacher['certificates'] = certificates
            teacher['available_times'] = available_times
            
            return render_template('teacher-profile.html', teacher=teacher)
            
    except Exception as e:
        print(f"获取教师信息错误: {e}")
        return "获取信息失败", 500
        
    finally:
        if conn:
            conn.close()

# 路由：退出登录
@app.route('/logout')
def logout():
    """
    处理退出登录请求
    清除session并重定向到首页
    """
    session.clear()
    return redirect(url_for('index'))

# 路由：关于我们页面
@app.route('/about')
def about():
    """
    关于我们页面
    """
    return render_template('about-us.html')

# 路由：课程选择页面
@app.route('/course-selection')
def course_selection():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    try:
        conn = get_db()
        if not conn:
            return "数据库连接失败", 500
            
        with conn.cursor() as cursor:
            # 修改查询，添加评分和评价数统计
            query = """
                SELECT 
                    c.id,
                    c.name,
                    c.description,
                    c.subject,
                    c.grade_level,
                    c.price,
                    c.course_type,
                    c.max_students,
                    c.current_students,
                    c.location,
                    c.online_url,
                    t.name as teacher_name,
                    t.avatar_url as teacher_avatar,
                    COALESCE(AVG(r.rating), 5.0) as rating,
                    COUNT(DISTINCT r.id) as rating_count,
                    COALESCE(
                        SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) * 100.0 / 
                        NULLIF(COUNT(r.id), 0), 
                        100
                    ) as positive_rate
                FROM courses c
                JOIN teachers t ON c.teacher_id = t.id
                LEFT JOIN ratings r ON t.id = r.teacher_id
                WHERE c.status = 'active'
                GROUP BY 
                    c.id, c.name, c.description, c.subject, 
                    c.grade_level, c.price, c.course_type,
                    c.max_students, c.current_students, c.location,
                    c.online_url, t.name, t.avatar_url
                ORDER BY c.created_at DESC
            """
            cursor.execute(query)
            courses = cursor.fetchall()
            
            # 为每个课程添加评价等级
            for course in courses:
                rate = course['positive_rate']
                if rate >= 95:
                    course['rating_level'] = '好评如潮'
                    course['rating_class'] = 'excellent'
                elif rate >= 80:
                    course['rating_level'] = '特别好评'
                    course['rating_class'] = 'very-good'
                elif rate >= 70:
                    course['rating_level'] = '多半好评'
                    course['rating_class'] = 'good'
                elif rate > 40:
                    course['rating_level'] = '褒贬不一'
                    course['rating_class'] = 'mixed'
                elif rate > 30:
                    course['rating_level'] = '多半差评'
                    course['rating_class'] = 'poor'
                else:
                    course['rating_level'] = '特别差评'
                    course['rating_class'] = 'very-poor'
            
            return render_template('course-selection.html', courses=courses)
            
    except Exception as e:
        print(f"数据库查询错误: {e}")
        return render_template('course-selection.html', courses=[])

# 处理课程报名的路由
@app.route('/enroll/<int:course_id>', methods=['POST'])
def enroll_course(course_id):
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': '请先登录'})
    
    try:
        cursor = mysql.connection.cursor()
        # 检查是否已经报名
        check_query = """
            SELECT id FROM enrollments 
            WHERE student_id = %s AND course_id = %s
        """
        cursor.execute(check_query, (session['user_id'], course_id))
        existing = cursor.fetchone()
        
        if existing:
            return jsonify({'success': False, 'message': '您已经报名过该课程'})
        
        # 创建新的报名记录
        insert_query = """
            INSERT INTO enrollments (student_id, course_id, enroll_date, status)
            VALUES (%s, %s, NOW(), 'pending')
        """
        cursor.execute(insert_query, (session['user_id'], course_id))
        mysql.connection.commit()
        cursor.close()
        
        return jsonify({'success': True, 'message': '报名成功'})
    except Exception as e:
        print(f"报名过程发生错误: {e}")
        return jsonify({'success': False, 'message': '报名失败，请稍后重试'})

# 路由：课程发布页面
@app.route('/course_publish')
@login_required
def course_publish():
    """
    课程发布页面
    显示教师已发布的课程列表和发布新课程的功能
    """
    if session.get('user_type') != 'teacher':
        return redirect(url_for('index'))
        
    try:
        conn = get_db()
        if not conn:
            return "数据库连接失败", 500
            
        with conn.cursor() as cursor:
            # 获取教师已发布的课程，评分从教师整体评分获取
            sql = """
                SELECT 
                    c.*,
                    COUNT(DISTINCT e.student_id) as enrolled_students,
                    (SELECT COALESCE(AVG(rating), 0) 
                     FROM ratings 
                     WHERE teacher_id = c.teacher_id) as avg_rating,
                    (SELECT COUNT(id) 
                     FROM ratings 
                     WHERE teacher_id = c.teacher_id) as rating_count
                FROM courses c
                LEFT JOIN enrollments e ON c.id = e.course_id
                WHERE c.teacher_id = %s
                GROUP BY c.id, c.name, c.description, c.subject, 
                         c.grade_level, c.price, c.status, c.created_at,
                         c.course_type, c.max_students, c.current_students,
                         c.location, c.online_url
                ORDER BY c.created_at DESC
            """
            cursor.execute(sql, (session.get('user_id'),))
            courses = cursor.fetchall()
            
            return render_template('course-publish.html', courses=courses)
            
    except Exception as e:
        print(f"获取课程列表错误: {e}")
        return "获取课程列表失败", 500
        
    finally:
        if conn:
            conn.close()

# 路由：处理课程发布
@app.route('/publish_course', methods=['POST'])
@login_required
def publish_course():
    """
    处理课程发布请求
    """
    if session.get('user_type') != 'teacher':
        return jsonify({'status': 'error', 'message': '权限不足'})
        
    try:
        data = request.get_json()
        
        # 验证必填字段
        required_fields = ['name', 'subject', 'grade_level', 'price', 'max_students', 
                         'course_type', 'description']
        for field in required_fields:
            if not data.get(field):
                return jsonify({
                    'status': 'error',
                    'message': f'请填写{field}'
                })
        
        conn = get_db()
        if not conn:
            return jsonify({
                'status': 'error',
                'message': '数据库连接失败'
            })
            
        with conn.cursor() as cursor:
            sql = """
                INSERT INTO courses (
                    name, subject, grade_level, price, max_students,
                    course_type, description, teacher_id, status,
                    location, created_at
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, 'active', %s, NOW()
                )
            """
            cursor.execute(sql, (
                data['name'],
                data['subject'],
                data['grade_level'],
                data['price'],
                data['max_students'],
                data['course_type'],
                data['description'],
                session.get('user_id'),
                data.get('location', '')
            ))
            conn.commit()
            
            return jsonify({
                'status': 'success',
                'message': '课程发布成功'
            })
            
    except Exception as e:
        print(f"发布课程错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '发布失败，请稍后重试'
        })
        
    finally:
        if conn:
            conn.close()

@app.route('/teacher_recommendation')
@login_required
def teacher_recommendation():
    """
    名师推荐页面
    仅学生可访问
    显示所有教师信息，包括评分、好评率等
    """
    if session.get('user_type') != 'student':
        return redirect(url_for('index'))
        
    try:
        conn = get_db()
        if not conn:
            return "数据库连接失败", 500
            
        with conn.cursor() as cursor:
            sql = """
                SELECT 
                    t.id,
                    t.name,
                    t.subjects,
                    t.introduction,
                    t.avatar_url,
                    t.years_of_experience,
                    COALESCE(AVG(r.rating), 5.0) as rating,
                    COUNT(r.id) as rating_count,
                    COALESCE(
                        SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) * 100.0 / 
                        NULLIF(COUNT(r.id), 0), 
                        100
                    ) as positive_rate
                FROM teachers t
                LEFT JOIN ratings r ON t.id = r.teacher_id
                GROUP BY 
                    t.id,
                    t.name,
                    t.subjects,
                    t.introduction,
                    t.avatar_url,
                    t.years_of_experience
                ORDER BY rating DESC, rating_count DESC
            """
            cursor.execute(sql)
            teachers = cursor.fetchall()
            
            # 设置每个教师的评价等级
            for teacher in teachers:
                rate = teacher['positive_rate']
                if rate >= 95:
                    teacher['rating_level'] = '好评如潮'
                    teacher['rating_class'] = 'excellent'
                elif rate >= 80:
                    teacher['rating_level'] = '特别好评'
                    teacher['rating_class'] = 'very-good'
                elif rate >= 70:
                    teacher['rating_level'] = '多半好评'
                    teacher['rating_class'] = 'good'
                elif rate > 40:
                    teacher['rating_level'] = '褒贬不一'
                    teacher['rating_class'] = 'mixed'
                elif rate > 30:
                    teacher['rating_level'] = '多半差评'
                    teacher['rating_class'] = 'poor'
                else:
                    teacher['rating_level'] = '特别差评'
                    teacher['rating_class'] = 'very-poor'
            
            return render_template('teacher-recommendation.html', teachers=teachers)
            
    except Exception as e:
        print(f"获取教师列表错误: {e}")
        return "获取信息失败", 500
        
    finally:
        if conn:
            conn.close()

# 配置文件上传
UPLOAD_FOLDER = 'static/uploads/avatars'  # 头像存储路径
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}  # 允许的文件类型

# 确保上传文件夹存在
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# 检查文件类型是否允许
def allowed_file(filename):
    """
    检查文件扩展名是否允许
    :param filename: 文件名
    :return: True/False
    """
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# 头像上传路由
@app.route('/upload_avatar', methods=['POST'])
@login_required
def upload_avatar():
    """
    处理头像上传
    要求用户必须登录
    """
    try:
        # 检查是否有文件
        if 'avatar' not in request.files:
            return jsonify({
                'status': 'error',
                'message': '没有选择文件'
            })
            
        file = request.files['avatar']
        
        # 检查文件名是否为空
        if file.filename == '':
            return jsonify({
                'status': 'error',
                'message': '没有选择文件'
            })
            
        # 检查文件类型并保存
        if file and allowed_file(file.filename):
            # 安全处理文件名
            filename = secure_filename(file.filename)
            # 使用用户ID和时间戳创建唯一文件名
            unique_filename = f"{session['user_id']}_{int(time.time())}_{filename}"
            # 完整的文件保存路径
            filepath = os.path.join(UPLOAD_FOLDER, unique_filename)
            
            # 保存文件
            file.save(filepath)
            
            # 更新数据库中的头像URL
            conn = get_db()
            if conn:
                try:
                    with conn.cursor() as cursor:
                        sql = "UPDATE teachers SET avatar_url = %s WHERE id = %s"
                        cursor.execute(sql, (
                            f"/static/uploads/avatars/{unique_filename}",
                            session['user_id']
                        ))
                        conn.commit()
                        
                        return jsonify({
                            'status': 'success',
                            'message': '头像上传成功',
                            'avatar_url': f"/static/uploads/avatars/{unique_filename}"
                        })
                finally:
                    conn.close()
                    
        return jsonify({
            'status': 'error',
            'message': '不支持的文件类型'
        })
        
    except Exception as e:
        print(f"头像上传错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '上传失败，请稍后重试'
        })

# 证书上传配置
CERTIFICATE_FOLDER = 'static/uploads/certificates'  # 证书存储路径
os.makedirs(CERTIFICATE_FOLDER, exist_ok=True)

# 证书上传路由
@app.route('/upload_certificate', methods=['POST'])
@login_required
def upload_certificate():
    """
    处理证书上传
    要求用户必须登录
    """
    try:
        # 检查是否有文件和证书名称
        if 'certificate' not in request.files:
            return jsonify({
                'status': 'error',
                'message': '没有选择文件'
            })
            
        file = request.files['certificate']
        cert_name = request.form.get('cert_name', '').strip()
        issue_date = request.form.get('issue_date', '')
        
        if not cert_name:
            return jsonify({
                'status': 'error',
                'message': '请输入证书名称'
            })
            
        if file.filename == '':
            return jsonify({
                'status': 'error',
                'message': '没有选择文件'
            })
            
        # 检查文件类型并保存
        if file and allowed_file(file.filename):
            # 安全处理文件名
            filename = secure_filename(file.filename)
            # 使用用户ID和时间戳创建唯一文件名
            unique_filename = f"cert_{session['user_id']}_{int(time.time())}_{filename}"
            # 完整的文件保存路径
            filepath = os.path.join(CERTIFICATE_FOLDER, unique_filename)
            
            # 保存文件
            file.save(filepath)
            
            # 更新数据库
            conn = get_db()
            if conn:
                try:
                    with conn.cursor() as cursor:
                        sql = """
                            INSERT INTO certificates 
                            (teacher_id, name, image_url, issue_date) 
                            VALUES (%s, %s, %s, %s)
                        """
                        cursor.execute(sql, (
                            session['user_id'],
                            cert_name,
                            f"/static/uploads/certificates/{unique_filename}",
                            issue_date
                        ))
                        conn.commit()
                        
                        # 获取新插入的证书ID
                        cert_id = cursor.lastrowid
                        
                        return jsonify({
                            'status': 'success',
                            'message': '证书上传成功',
                            'certificate': {
                                'id': cert_id,
                                'name': cert_name,
                                'image_url': f"/static/uploads/certificates/{unique_filename}",
                                'issue_date': issue_date
                            }
                        })
                finally:
                    conn.close()
                    
        return jsonify({
            'status': 'error',
            'message': '不支持的文件类型'
        })
        
    except Exception as e:
        print(f"证书上传错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '上传失败，请稍后重试'
        })

# 更新教师信息路由
@app.route('/update_teacher_info', methods=['POST'])
@login_required
def update_teacher_info():
    """
    处理教师信息更新
    """
    try:
        data = request.get_json()
        field = data.get('field')
        value = data.get('value')
        
        # 验证字段
        allowed_fields = ['years_of_experience', 'subjects', 'phone', 'email', 'introduction']
        if field not in allowed_fields:
            return jsonify({
                'status': 'error',
                'message': '不允许的字段'
            })
            
        # 连接数据库
        conn = get_db()
        if not conn:
            return jsonify({
                'status': 'error',
                'message': '数据库连接失败'
            })
            
        try:
            with conn.cursor() as cursor:
                # 根据字段类型行特殊处理
                if field == 'years_of_experience':
                    try:
                        value = int(value)
                        if value < 0:
                            return jsonify({
                                'status': 'error',
                                'message': '教龄不能为负数'
                            })
                    except ValueError:
                        return jsonify({
                            'status': 'error',
                            'message': '请输入有效的数字'
                        })
                        
                elif field == 'phone':
                    if not value.isdigit() or len(value) != 11:
                        return jsonify({
                            'status': 'error',
                            'message': '请输入有效的11位手机号'
                        })
                        
                elif field == 'email':
                    if '@' not in value or '.' not in value:
                        return jsonify({
                            'status': 'error',
                            'message': '请输入有效的邮箱地址'
                        })
                
                # 更新数据库
                sql = f"UPDATE teachers SET {field} = %s WHERE id = %s"
                cursor.execute(sql, (value, session['user_id']))
                conn.commit()
                
                return jsonify({
                    'status': 'success',
                    'message': '更新成功',
                    'value': value
                })
                
        finally:
            conn.close()
            
    except Exception as e:
        print(f"更新教师信息错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '更新失败，请稍后重试'
        })

# 更新教师可用时间路由
@app.route('/update_available_times', methods=['POST'])
@login_required
def update_available_times():
    """
    处理教师可用时间更新
    """
    try:
        data = request.get_json()
        time_slots = data.get('time_slots', [])
        
        # 连接数据库
        conn = get_db()
        if not conn:
            return jsonify({
                'status': 'error',
                'message': '数据库连接失败'
            })
            
        try:
            with conn.cursor() as cursor:
                # 先删除原有的时间安排
                sql = "DELETE FROM available_times WHERE teacher_id = %s"
                cursor.execute(sql, (session['user_id'],))
                
                # 插入新的时间安排
                if time_slots:
                    sql = """
                        INSERT INTO available_times 
                        (teacher_id, day_of_week, time_slot) 
                        VALUES (%s, %s, %s)
                    """
                    for slot in time_slots:
                        cursor.execute(sql, (
                            session['user_id'],
                            slot['day'],
                            slot['time']
                        ))
                
                conn.commit()
                return jsonify({
                    'status': 'success',
                    'message': '时间安排已更新'
                })
                
        finally:
            conn.close()
            
    except Exception as e:
        print(f"更新时间安排错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '更新失败，请稍后重试'
        })

# 修改密码路由
@app.route('/change_password', methods=['POST'])
@login_required
def change_password():
    """
    处理密码修改
    """
    try:
        data = request.get_json()
        old_password = data.get('old_password')
        new_password = data.get('new_password')
        confirm_password = data.get('confirm_password')
        
        # 验证数据
        if not all([old_password, new_password, confirm_password]):
            return jsonify({
                'status': 'error',
                'message': '所有字段都必须填写'
            })
            
        if new_password != confirm_password:
            return jsonify({
                'status': 'error',
                'message': '两次输入的新密码不一致'
            })
            
        if len(new_password) < 6:
            return jsonify({
                'status': 'error',
                'message': '密码长度不能少于6位'
            })
            
        # 连接数据库
        conn = get_db()
        if not conn:
            return jsonify({
                'status': 'error',
                'message': '数据库连接失败'
            })
            
        try:
            with conn.cursor() as cursor:
                # 验证旧密码
                table = 'teachers' if session.get('user_type') == 'teacher' else 'students'
                sql = f"SELECT password FROM {table} WHERE id = %s"
                cursor.execute(sql, (session['user_id'],))
                user = cursor.fetchone()
                
                # 使用明文密码验证
                if user['password'] != old_password:
                    return jsonify({
                        'status': 'error',
                        'message': '原密码错误'
                    })
                    
                # 更新密码
                sql = f"UPDATE {table} SET password = %s WHERE id = %s"
                # 存储明文密码
                cursor.execute(sql, (new_password, session['user_id']))
                conn.commit()
                
                return jsonify({
                    'status': 'success',
                    'message': '密码修改成功'
                })
                
        finally:
            conn.close()
            
    except Exception as e:
        print(f"修改密码错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '修改失败，请稍后重试'
        })

# 一次性更新所有用户密码为加密密码（仅在需要时使用）
@app.route('/update_all_passwords', methods=['POST'])
def update_all_passwords():
    """
    将所有用户的明文密码更新为加密密码
    注意：这个路由应该在使用后删除或禁用
    """
    try:
        conn = get_db()
        if not conn:
            return jsonify({
                'status': 'error',
                'message': '数据库连接失败'
            })
            
        try:
            with conn.cursor() as cursor:
                # 更新教师密码
                sql = "SELECT id FROM teachers"
                cursor.execute(sql)
                teachers = cursor.fetchall()
                
                for teacher in teachers:
                    hashed_password = generate_password_hash('password')
                    sql = "UPDATE teachers SET password = %s WHERE id = %s"
                    cursor.execute(sql, (hashed_password, teacher['id']))
                
                # 更新学生密码
                sql = "SELECT id FROM students"
                cursor.execute(sql)
                students = cursor.fetchall()
                
                for student in students:
                    hashed_password = generate_password_hash('password')
                    sql = "UPDATE students SET password = %s WHERE id = %s"
                    cursor.execute(sql, (hashed_password, student['id']))
                
                conn.commit()
                return jsonify({
                    'status': 'success',
                    'message': '所有用户密码已更新为加密密码'
                })
                
        finally:
            conn.close()
            
    except Exception as e:
        print(f"更新密码错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '更新失败'
        })

# 添加全局上下文处理器
@app.context_processor
def inject_user_type():
    """
    向所有模板注入用户类型信息
    """
    return {
        'user_type': session.get('user_type'),
        'user_id': session.get('user_id'),
        'username': session.get('username')
    }

# 路由：教师详情页面
@app.route('/teacher/<int:teacher_id>')
@login_required
def teacher_detail(teacher_id):
    """
    教师详情页面
    显示教师的详细信息、评分分布、课程信息等
    """
    if session.get('user_type') != 'student':
        return redirect(url_for('index'))
        
    try:
        conn = get_db()
        if not conn:
            return "数据库连接失败", 500
            
        with conn.cursor() as cursor:
            # 获取教师基本信息和统计数据，明确指定所需字段
            sql = """
                SELECT 
                    t.id,
                    t.username,
                    t.name,
                    t.phone,
                    t.email,
                    t.years_of_experience,
                    t.subjects,
                    t.introduction,
                    t.avatar_url,
                    t.created_at,
                    COALESCE(AVG(r.rating), 5.0) as rating,
                    COUNT(r.id) as rating_count,
                    COALESCE(
                        SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) * 100.0 / 
                        NULLIF(COUNT(r.id), 0), 
                        100
                    ) as positive_rate
                FROM teachers t
                LEFT JOIN ratings r ON t.id = r.teacher_id
                WHERE t.id = %s
                GROUP BY t.id, t.username, t.name, t.phone, t.email, 
                         t.years_of_experience, t.subjects, t.introduction, 
                         t.avatar_url, t.created_at
            """
            cursor.execute(sql, (teacher_id,))
            teacher = cursor.fetchone()
            
            if not teacher:
                return "教师不存在", 404
            
            # 获取评分分布
            sql = """
                SELECT 
                    rating,
                    COUNT(*) as count
                FROM ratings
                WHERE teacher_id = %s
                GROUP BY rating
            """
            cursor.execute(sql, (teacher_id,))
            ratings = cursor.fetchall()
            
            # 计算评分分布百分比
            total_ratings = sum(r['count'] for r in ratings)
            rating_distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0}
            if total_ratings > 0:
                for r in ratings:
                    rating_distribution[int(r['rating'])] = (r['count'] / total_ratings) * 100
            
            teacher['rating_distribution'] = rating_distribution
            
            # 获取教师的课程
            sql = """
                SELECT * FROM courses 
                WHERE teacher_id = %s AND status = 'active'
            """
            cursor.execute(sql, (teacher_id,))
            teacher['courses'] = cursor.fetchall()
            
            # 获取教师证书
            sql = "SELECT * FROM certificates WHERE teacher_id = %s"
            cursor.execute(sql, (teacher_id,))
            teacher['certificates'] = cursor.fetchall()
            
            # 获取评价详情
            sql = """
                SELECT 
                    r.*,
                    s.name as student_name,
                    s.avatar_url as student_avatar,
                    DATE_FORMAT(r.created_at, '%%Y-%%m-%%d %%H:%%i') as formatted_date
                FROM ratings r
                LEFT JOIN students s ON r.student_id = s.id
                WHERE r.teacher_id = %s
                ORDER BY r.created_at DESC
            """
            cursor.execute(sql, (teacher_id,))
            teacher['ratings'] = cursor.fetchall()
            
            # 设置评价等级
            rate = teacher['positive_rate']
            if rate >= 95:
                teacher['rating_level'] = '好评如潮'
                teacher['rating_class'] = 'excellent'
            elif rate >= 80:
                teacher['rating_level'] = '特别好评'
                teacher['rating_class'] = 'very-good'
            elif rate >= 70:
                teacher['rating_level'] = '多半好评'
                teacher['rating_class'] = 'good'
            elif rate > 40:
                teacher['rating_level'] = '褒贬不一'
                teacher['rating_class'] = 'mixed'
            elif rate > 30:
                teacher['rating_level'] = '多半差评'
                teacher['rating_class'] = 'poor'
            else:
                teacher['rating_level'] = '特别差评'
                teacher['rating_class'] = 'very-poor'
            
            print("Debug - Teacher data:", teacher)  # 添加调试信息
            return render_template('teacher-detail.html', teacher=teacher)
            
    except Exception as e:
        print(f"获取教师详情错误: {e}")  # 打印具体错误信息
        return "获取信息失败", 500
        
    finally:
        if conn:
            conn.close()

# 路由：更新课程
@app.route('/update_course/<int:course_id>', methods=['POST'])
@login_required
def update_course(course_id):
    if session.get('user_type') != 'teacher':
        return jsonify({'status': 'error', 'message': '权限不足'})
        
    try:
        data = request.get_json()
        
        conn = get_db()
        if not conn:
            return jsonify({'status': 'error', 'message': '数据库连接失败'})
            
        with conn.cursor() as cursor:
            # 验证课程所有权
            cursor.execute("""
                SELECT teacher_id FROM courses 
                WHERE id = %s
            """, (course_id,))
            course = cursor.fetchone()
            
            if not course or course['teacher_id'] != session.get('user_id'):
                return jsonify({'status': 'error', 'message': '无权修改此课程'})
            
            # 更新课程信息
            sql = """
                UPDATE courses 
                SET name = %s, subject = %s, grade_level = %s,
                    price = %s, max_students = %s, course_type = %s,
                    description = %s, location = %s
                WHERE id = %s AND teacher_id = %s
            """
            cursor.execute(sql, (
                data['name'],
                data['subject'],
                data['grade_level'],
                data['price'],
                data['max_students'],
                data['course_type'],
                data['description'],
                data.get('location', ''),
                course_id,
                session.get('user_id')
            ))
            conn.commit()
            
            return jsonify({
                'status': 'success',
                'message': '课程更新成功'
            })
            
    except Exception as e:
        print(f"更新课程错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '更新失败，请稍后重试'
        })
        
    finally:
        if conn:
            conn.close()

# 路由：删除课程
@app.route('/delete_course/<int:course_id>', methods=['POST'])
@login_required
def delete_course(course_id):
    if session.get('user_type') != 'teacher':
        return jsonify({'status': 'error', 'message': '权限不足'})
        
    try:
        conn = get_db()
        if not conn:
            return jsonify({'status': 'error', 'message': '数据库连接失败'})
            
        with conn.cursor() as cursor:
            # 验证课程所有权
            cursor.execute("""
                SELECT teacher_id FROM courses 
                WHERE id = %s
            """, (course_id,))
            course = cursor.fetchone()
            
            if not course or course['teacher_id'] != session.get('user_id'):
                return jsonify({'status': 'error', 'message': '无权删除此课程'})
            
            # 删除课程
            cursor.execute("""
                DELETE FROM courses 
                WHERE id = %s AND teacher_id = %s
            """, (course_id, session.get('user_id')))
            conn.commit()
            
            return jsonify({
                'status': 'success',
                'message': '课程删除成功'
            })
            
    except Exception as e:
        print(f"删除课程错误: {e}")
        return jsonify({
            'status': 'error',
            'message': '删除失败，请稍后重试'
        })
        
    finally:
        if conn:
            conn.close()

# 启动应用
if __name__ == '__main__':
    # 在开发环境中设置debug=True，生产环境要设置为False
    app.run(debug=True, host='0.0.0.0', port=5000)

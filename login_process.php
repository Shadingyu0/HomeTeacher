<?php
session_start();

// 数据库连接配置
$host = 'localhost';
$dbname = 'tutor_system';
$username = 'root';
$password = '123456';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die(json_encode(['status' => 'error', 'message' => '数据库连接失败']));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    $userType = $_POST['userType'] ?? 'student';

    if (empty($username) || empty($password)) {
        die(json_encode(['status' => 'error', 'message' => '用户名和密码不能为空']));
    }

    try {
        // 根据用户类型选择不同的表
        $table = ($userType === 'student') ? 'students' : 'teachers';
        
        // 查询用户
        $stmt = $pdo->prepare("SELECT * FROM {$table} WHERE username = ?");
        $stmt->execute([$username]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && password_verify($password, $user['password'])) {
            // 登录成功
            $_SESSION['user_id'] = $user['id'];
            $_SESSION['username'] = $user['username'];
            $_SESSION['user_type'] = $userType;

            echo json_encode([
                'status' => 'success',
                'message' => '登录成功',
                'redirect' => $userType === 'student' ? 'student-profile.html' : 'teacher-profile.html'
            ]);
        } else {
            echo json_encode(['status' => 'error', 'message' => '用户名或密码错误']);
        }
    } catch(PDOException $e) {
        echo json_encode(['status' => 'error', 'message' => '登录失败，请稍后重试']);
    }
}
?> 
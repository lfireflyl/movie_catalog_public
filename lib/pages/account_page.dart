import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_state.dart';
import '../style/movies_list_style.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  AccountPageState createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  String? _loggedInUser;
  String? _userRole;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<Map<String, dynamic>> _users = [];

  Future<void> _loadUsers() async {
    final List<Map<String, dynamic>> users = await loadUsers();
    setState(() {
      _users = users;
    });
  }

  Future<List<Map<String, dynamic>>> loadUsers() async {
    final String response = await rootBundle.loadString('/users.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((user) => Map<String, dynamic>.from(user)).toList();
  }

  Future<void> _saveSession(String username, String role, int userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('userID', userID);
    prefs.setString('username', username);
    prefs.setString('role', role);
  }

  Future<void> _loadSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInUser = prefs.getString('username');
      _userRole = prefs.getString('role');
    });
  }

  void _login(String username, String password) {
    final user = _users.firstWhere(
      (user) => user['username'] == username && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      Provider.of<UserState>(context, listen: false).login(
        user['username'],
        user['role'],
      );

      _saveSession(user['username'], user['role'], user['userID']);
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неверные данные для входа')),
      );
    }
  }


  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('role');
    prefs.remove('userID');

    setState(() {
      _loggedInUser = null;
      _userRole = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Аккаунт'),
      ),
      body: Center(
        child: _loggedInUser == null ? _buildLoginForm() : _buildProfile(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Имя пользователя',
              labelStyle: const TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppStyles.primaryColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppStyles.primaryColor),
              ),
            ),
            cursorColor: AppStyles.primaryColor,
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Пароль',
              labelStyle: TextStyle(color: Colors.grey),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppStyles.primaryColor),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppStyles.primaryColor),
              ),
            ),
            cursorColor: AppStyles.primaryColor,
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _login(_usernameController.text, _passwordController.text);
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppStyles.primaryColor,
            ),
            child: Text('Войти'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Добро пожаловать, $_loggedInUser!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Роль: $_userRole',
          style: TextStyle(fontSize: 16),
        ),
        if (_userRole == 'admin') ...[
          SizedBox(height: 20),
          Text(
            'У вас есть права администратора.',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: _logout,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppStyles.primaryColor,
          ),
          child: Text('Выйти'),
        ),
      ],
    );
  }
}

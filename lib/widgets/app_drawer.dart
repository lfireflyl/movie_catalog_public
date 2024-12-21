import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/admin_page.dart';
import '../providers/user_state.dart';
import '../pages/home_page.dart';
import '../pages/favorites_page.dart';
import '../pages/search_page.dart';
import '../pages/collections_page.dart';
import '../pages/account_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<UserState>(
        builder: (context, userState, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  userState.isLoggedIn
                      ? 'Привет, ${userState.username}!'
                      : 'Меню',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: Icon(Icons.movie_filter),
                title: Text('Сейчас смотрят'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Избранное'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FavoritesPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Поиск'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.collections),
                title: Text('Подборки'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CollectionsPage()),
                  );
                },
              ),
              if (userState.role == 'admin')
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Управление подборками'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminPanel()),
                    );
                  },
                ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text(userState.isLoggedIn ? 'Аккаунт' : 'Войти'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountPage()),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

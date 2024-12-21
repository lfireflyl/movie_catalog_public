class User {
  int userId;
  List<int> cardIds;

  User({required this.userId, required this.cardIds});

  void toggleCard(int cardId) {
    if (cardIds.contains(cardId)) {
      cardIds.remove(cardId);  
    } else {
      cardIds.add(cardId);    
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'cardIds': cardIds,
    };
  }

  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      cardIds: List<int>.from(json['cardIds']),
    );
  }
}

class UsersData {
  List<User> users;

  UsersData({required this.users});

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
    };
  }

  static UsersData fromJson(Map<String, dynamic> json) {
    return UsersData(
      users: (json['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList(),
    );
  }
}


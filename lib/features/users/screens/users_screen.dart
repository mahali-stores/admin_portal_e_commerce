import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/users_controller.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UsersController controller = Get.put(UsersController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.users.isEmpty) {
          return const Center(child: Text('No users found.'));
        }
        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(user.role.substring(0, 1).toUpperCase()),
                ),
                title: Text('${user.firstName ?? ''} ${user.lastName ?? 'No Name Provided'}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text('Role: ${user.role}'),
                    Text('Joined: ${DateFormat.yMMMd().format(user.createdAt.toDate())}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      }),
    );
  }
}
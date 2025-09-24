import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/viewmodels/auth_controller.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Center(
              child: Text(
                'Mon Compte',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              context.pop(); // ferme le drawer
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Mes commandes'),
            onTap: () {
              context.pop();
              context.push('/orders');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              context.pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }
}

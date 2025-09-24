import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/viewmodels/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Utilisateur non connecté')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informations personnelles',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Email : ${user.email}'),
            Text('UID : ${user.uid}', style: const TextStyle(fontSize: 12, color: Colors.grey)),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            const Text('Navigation rapide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Mon panier'),
              onTap: () => context.push('/cart'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Mes commandes'),
              onTap: () => context.push('/orders'),
            ),

            const Spacer(),

            Center(
              child: FilledButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

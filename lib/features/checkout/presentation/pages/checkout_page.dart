import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../presentation/viewmodels/orders_viewmodel.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Panier vide'))
                  : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final it = items[i];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(it.thumbnail, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                    title: Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${it.quantity} × \$${it.price.toStringAsFixed(2)}'),
                    trailing: Text('\$${(it.price * it.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(child: Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Text('\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: items.isEmpty
                    ? null
                    : () async {
                  final success = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _MockStripeSheet(amount: total),
                  );
                  if (success == true) {
                    // créer commande + vider panier
                    ref.read(ordersProvider.notifier).addOrder(items, total);
                    ref.read(cartProvider.notifier).clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Paiement confirmé — commande créée ✅')),
                      );
                      Navigator.of(context).pop(); // retour au panier
                    }
                  }
                },
                child: const Text('Payer (mock Stripe)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockStripeSheet extends StatefulWidget {
  final double amount;
  const _MockStripeSheet({required this.amount});

  @override
  State<_MockStripeSheet> createState() => _MockStripeSheetState();
}

class _MockStripeSheetState extends State<_MockStripeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _card = TextEditingController();
  final _exp = TextEditingController();
  final _cvc = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _card.dispose();
    _exp.dispose();
    _cvc.dispose();
    super.dispose();
  }

  String? _validateCard(String? v) {
    if (v == null || v.trim().isEmpty) return 'Numéro requis';
    final digits = v.replaceAll(RegExp(r'\s+|-'), '');
    if (digits.length < 16) return 'Numéro invalide';
    return null;
  }

  String? _validateExp(String? v) {
    if (v == null || v.trim().isEmpty) return 'MM/YY requis';
    final parts = v.split('/');
    if (parts.length != 2) return 'Format MM/YY';
    final mm = int.tryParse(parts[0]);
    final yy = int.tryParse(parts[1]);
    if (mm == null || yy == null || mm < 1 || mm > 12) return 'Mois invalide';
    return null;
  }

  String? _validateCvc(String? v) {
    if (v == null || v.trim().length < 3) return 'CVC invalide';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [BoxShadow(blurRadius: 16, color: Colors.black26)],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(color: scheme.primary.withOpacity(.2), borderRadius: BorderRadius.circular(4)),
                ),
                const SizedBox(height: 16),
                Text('Paiement sécurisé (mock)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _card,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de carte',
                    hintText: '4242 4242 4242 4242',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  validator: _validateCard,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _exp,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Expiration (MM/YY)'),
                        validator: _validateExp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvc,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'CVC'),
                        validator: _validateCvc,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _processing
                        ? null
                        : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _processing = true);
                      await Future.delayed(const Duration(seconds: 1)); // simulate processing
                      if (mounted) Navigator.of(context).pop(true); // succès
                    },
                    child: _processing
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('Payer \$${widget.amount.toStringAsFixed(2)}'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _processing ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

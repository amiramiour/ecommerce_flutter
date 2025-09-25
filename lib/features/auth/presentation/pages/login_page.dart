import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:form_validator/form_validator.dart';
import '../viewmodels/auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  late final AnimationController _anim;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signIn(
          _email.text.trim(),
          _password.text,
        );
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final msg = mapFirebaseAuthError(state.error!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } else {
      if (!mounted) return;
      context.go('/catalog'); // route protégée
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 12,
                // utilisation de withValues
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          Icon(Icons.shopping_bag,
                              size: 48, color: theme.colorScheme.primary),
                          const SizedBox(height: 12),
                          Text("Bienvenue",
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text("Connecte-toi pour continuer",
                              style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _email,
                            autofillHints: const [AutofillHints.email],
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: ValidationBuilder().email().build(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            autofillHints: const [AutofillHints.password],
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                            validator: ValidationBuilder()
                                .minLength(6, "Au moins 6 caractères")
                                .build(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: auth.isLoading ? null : _submit,
                              style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14))),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Text("Se connecter"),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text("ou",
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // --- bouton Google ---
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons
                                  .login), // (tu peux mettre un asset logo Google)
                              label: const Text("Continuer avec Google"),
                              onPressed: auth.isLoading
                                  ? null
                                  : () async {
                                      await ref
                                          .read(authControllerProvider.notifier)
                                          .signInWithGoogle();
                                      final state =
                                          ref.read(authControllerProvider);
                                      if (state.hasError) {
                                        final msg =
                                            mapFirebaseAuthError(state.error!);
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                                SnackBar(content: Text(msg)));
                                      } else {
                                        if (!mounted) return;
                                        context.go('/catalog');
                                      }
                                    },
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text("Créer un compte"),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

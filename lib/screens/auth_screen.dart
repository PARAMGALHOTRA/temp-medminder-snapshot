import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medminder/screens/welcome_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  final String _confirmPassword = '';
  String _fullName = '';
  bool _isLogin = true;
  String? _error;
  bool _loading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: _email, password: _password);
      } else {
        if (_password != _confirmPassword) {
          setState(() {
            _error = 'Passwords do not match';
            _loading = false;
          });
          return;
        }
        final cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
        await cred.user?.updateDisplayName(_fullName);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message ?? e.code;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Header
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create an Account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Sign in to continue' : 'Sign up to get started',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 48),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isLogin)
                        TextFormField(
                          decoration: _buildInputDecoration(
                              theme, 'Full Name', Icons.person_outline),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter your full name'
                              : null,
                          onSaved: (v) => _fullName = v!.trim(),
                        ),
                      if (!_isLogin) const SizedBox(height: 16),
                      TextFormField(
                        decoration: _buildInputDecoration(
                            theme, 'Email', Icons.email_outlined),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
                        onSaved: (v) => _email = v!.trim(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _buildInputDecoration(
                            theme, 'Password', Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                  _showPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: theme.colorScheme.onSurface
                                      .withAlpha(153)),
                              onPressed: () => setState(
                                  () => _showPassword = !_showPassword),
                            )),
                        obscureText: !_showPassword,
                        validator: (v) => v == null || v.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                        onSaved: (v) => _password = v!,
                      ),
                      if (!_isLogin) const SizedBox(height: 16),
                      if (!_isLogin)
                        TextFormField(
                          decoration: _buildInputDecoration(
                              theme, 'Confirm Password', Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _showConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: theme.colorScheme.onSurface
                                        .withAlpha(153)),
                                onPressed: () => setState(() =>
                                    _showConfirmPassword =
                                        !_showConfirmPassword),
                              )),
                          obscureText: !_showConfirmPassword,
                          validator: (v) =>
                              v != _password ? 'Passwords do not match' : null,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_error != null)
                  Text(
                    _error!,
                    style: GoogleFonts.manrope(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),

                // Submit Button
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                const SizedBox(height: 16),

                // Toggle Auth Mode
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                      _error = null;
                      _formKey.currentState?.reset();
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Don\'t have an account? Sign Up'
                        : 'Already have an account? Login',
                    style: GoogleFonts.manrope(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      ThemeData theme, String label, IconData prefixIcon,
      {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(
          color: theme.colorScheme.onSurface.withAlpha(153)),
      prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
    );
  }
}

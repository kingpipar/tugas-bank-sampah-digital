import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();
  String? _jenisKelamin;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _emailController.text.trim(),
      _passwordController.text,
      nama: _namaController.text.trim(),
      rt: _rtController.text.trim(),
      rw: _rwController.text.trim(),
      jenisKelamin: _jenisKelamin ?? '',
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                      colorScheme.surface,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_rounded,
                            size: 64,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Daftar Warga',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lengkapi data diri Anda untuk mendaftar',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Card(
                          elevation: 8,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _namaController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: _inputDecoration(
                                      'Nama Lengkap',
                                      Icons.badge_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Nama tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: _jenisKelamin,
                                    decoration: _inputDecoration(
                                      'Jenis Kelamin',
                                      Icons.wc_outlined,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Laki-laki',
                                        child: Text('Laki-laki'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Perempuan',
                                        child: Text('Perempuan'),
                                      ),
                                    ],
                                    onChanged: (val) =>
                                        setState(() => _jenisKelamin = val),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Pilih jenis kelamin';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _rtController,
                                          keyboardType: TextInputType.number,
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          decoration: _inputDecoration(
                                            'RT',
                                            Icons.home_work_outlined,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Wajib diisi';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _rwController,
                                          keyboardType: TextInputType.number,
                                          autovalidateMode:
                                              AutovalidateMode.onUserInteraction,
                                          decoration: _inputDecoration(
                                            'RW',
                                            Icons.holiday_village_outlined,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Wajib diisi';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: _inputDecoration(
                                      'Email',
                                      Icons.email_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email tidak boleh kosong';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password tidak boleh kosong';
                                      }
                                      if (value.length < 6) {
                                        return 'Password minimal 6 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (auth.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12),
                                      child: Text(
                                        auth.errorMessage!,
                                        style: TextStyle(
                                          color: colorScheme.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: auth.isLoading
                                        ? null
                                        : _handleRegister,
                                    icon: const Icon(Icons.app_registration),
                                    label: const Text('Daftar'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: auth.isLoading
                                        ? null
                                        : () {
                                            auth.clearError();
                                            Navigator.pop(context);
                                          },
                                    child: Text(
                                      'Sudah punya akun? Masuk',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (auth.isLoading)
                const LoadingOverlay(message: 'Mendaftarkan akun...'),
            ],
          );
        },
      ),
    );
  }
}

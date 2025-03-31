import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _nikController = TextEditingController();
  late UserRole _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Get the selected role from route arguments or default to foreman
    _selectedRole = UserRole.foreman;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is UserRole) {
        setState(() {
          _selectedRole = args;
        });
        
        // Use default admin NIK for admin role
        if (_selectedRole == UserRole.admin) {
          _nikController.text = AppConstants.defaultAdminNik;
        }
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            
            if (state is Authenticated) {
              // Navigate based on the user role
              if (state.user.isAdmin) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.adminDashboard,
                  (route) => false,
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.home,
                  (route) => false,
                );
              }
            } else if (state is AdminVerified) {
              // Admin PIN verified, proceed to login
              context.read<AuthBloc>().add(LoginEvent(
                pin: _pinController.text.trim(),
                role: UserRole.admin,
              ));
            } else if (state is AdminVerificationFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is AuthenticationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32.0),
                // Only show NIK field for admin
                if (_selectedRole == UserRole.admin) ...[
                  _buildNikField(),
                  const SizedBox(height: 16.0),
                ],
                _buildPinField(),
                const SizedBox(height: 24.0),
                _buildLoginButton(),
                const SizedBox(height: 16.0),
                _buildBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String roleText;
    IconData roleIcon;
    
    switch (_selectedRole) {
      case UserRole.admin:
        roleText = 'Admin Login';
        roleIcon = Icons.admin_panel_settings;
        break;
      case UserRole.foreman:
        roleText = 'Foreman Login';
        roleIcon = Icons.engineering;
        break;
      case UserRole.inspector:
        roleText = 'Inspector Login';
        roleIcon = Icons.search;
        break;
    }
    
    return Column(
      children: [
        Icon(
          roleIcon,
          size: 64.0,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 16.0),
        Text(
          roleText,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8.0),
        Text(
          _selectedRole == UserRole.admin 
              ? 'Enter your NIK and PIN to continue'
              : 'Enter your PIN to continue',
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNikField() {
    return AppTextField(
      label: 'NIK',
      controller: _nikController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'NIK is required';
        }
        return null;
      },
      prefixIcon: Icons.badge,
    );
  }

  Widget _buildPinField() {
    return AppTextField(
      label: 'PIN',
      controller: _pinController,
      keyboardType: TextInputType.number,
      obscureText: true,
      validator: (value) => ValidationUtils.validatePin(
        value,
        minLength: AppConstants.minPinLength,
        maxLength: AppConstants.maxPinLength,
      ),
      prefixIcon: Icons.lock,
    );
  }

  Widget _buildLoginButton() {
    return AppButton(
      text: 'Login',
      onPressed: _handleLogin,
      isLoading: _isLoading,
      isFullWidth: true,
      icon: Icons.login,
    );
  }

  Widget _buildBackButton() {
    return AppButton(
      text: 'Back',
      onPressed: () => Navigator.pop(context),
      type: AppButtonType.outline,
      isFullWidth: true,
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final pin = _pinController.text.trim();
      
      if (_selectedRole == UserRole.admin) {
        final nik = _nikController.text.trim();
        
        // Verify NIK first
        if (nik != AppConstants.defaultAdminNik) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid NIK')),
          );
          return;
        }
        
        // Then verify PIN
        context.read<AuthBloc>().add(VerifyAdminPinEvent(pin: pin));
      } else {
        // For foreman or inspector, login directly
        context.read<AuthBloc>().add(LoginEvent(pin: pin, role: _selectedRole));
      }
    }
  }
}

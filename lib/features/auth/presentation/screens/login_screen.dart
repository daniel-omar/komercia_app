import 'package:flutter/gestures.dart';
import 'package:komercia_app/features/auth/presentation/providers/biometric_provider.dart';
import 'package:komercia_app/features/shared/infrastructure/providers/no_space_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:komercia_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:komercia_app/features/auth/presentation/providers/providers.dart';
import 'package:komercia_app/features/shared/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    // Solo se llama una vez al construir el widget por primera vez
    Future.microtask(() {
      ref.read(biometricProvider.notifier).checkFingerprint();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final biometricState = ref.watch(biometricProvider);

    ref.listen(biometricProvider, (previous, next) {
      if (next.isFingerprintEnabled) {
        // Realizar algún cambio si es necesario
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: GeometricalBackground(
              child: SingleChildScrollView(
        // physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!biometricState.isFingerprintEnabled) ...[
              const SizedBox(height: 80),
              // Icon Banner
              const Icon(
                Icons.account_box,
                color: Colors.white,
                size: 100,
              ),
              const SizedBox(height: 200),
            ],
            Container(
              height: biometricState.isFingerprintEnabled
                  ? size.height
                  : (size.height - 260), // 80 los dos sizebox y 100 el ícono
              width: double.infinity,
              decoration: BoxDecoration(
                color: scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                        biometricState.isFingerprintEnabled ? 0 : 100)),
              ),
              child: biometricState.isFingerprintEnabled
                  ? const _Biometric()
                  : const _LoginForm(),
            ),
          ],
        ),
      ))),
    );
  }
}

Future<void> verificarHuella(BuildContext context, WidgetRef ref) async {
  final biometricState = ref.read(biometricProvider);

  // Si la huella está habilitada, proceder con la autenticación
  if (biometricState.hasFingerprintRegistered) {
    final exito = await ref
        .read(biometricProvider.notifier)
        .authenticateWithFingerprint();
    if (!exito) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticación fallida')),
      ); // Lógica para continuar al home
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('correo');
    final clave = prefs.getString('clave');

    if (correo == null && clave == null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se encontraron credenciales guardadas')),
      );
      return;
    }

    ref.read(authProvider.notifier).loginUser(correo!, clave!);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Por favor ingrese sus credenciales')),
    );
  }
}

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      showSnackbar(context, next.errorMessage);
    });
    final biometricState = ref.watch(biometricProvider);

    final textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centra el contenido en el eje vertical
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centra en el eje horizontal
        children: [
          Text('Login', style: textStyles.titleLarge),
          const SizedBox(height: 50),
          CustomTextFormField(
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            onChanged: ref.read(loginFormProvider.notifier).onEmailChange,
            errorMessage:
                loginForm.isFormPosted ? loginForm.email.errorMessage : null,
            listTextInputFormatter: [NoSpaceFormatter()],
          ),
          const SizedBox(height: 30),
          CustomTextFormField(
            label: 'Contraseña',
            obscureText: loginForm.isObscurePassword,
            onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
            onFieldSubmitted: (_) =>
                ref.read(loginFormProvider.notifier).onFormSubmit(),
            errorMessage:
                loginForm.isFormPosted ? loginForm.password.errorMessage : null,
            listTextInputFormatter: [NoSpaceFormatter()],
            hasSufix: true,
            onSufix: ref.read(loginFormProvider.notifier).onSufix,
            suffixIcon: Icons.remove_red_eye,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: CustomFilledButton(
                text: 'Ingresar',
                buttonColor: Colors.black,
                onPressed: loginForm.isPosting
                    ? null
                    : ref.read(loginFormProvider.notifier).onFormSubmit),
          ),
          if (biometricState.hasFingerprintRegistered) ...[
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.fingerprint),
              onPressed: () => verificarHuella(context, ref),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                iconSize: 40,
              ),
            ),
          ],
          const Spacer(flex: 2),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     const Text('¿No tienes cuenta?'),
          //     TextButton(
          //         onPressed: () => context.push('/register'),
          //         child: const Text('Crea una aquí'))
          //   ],
          // ),
          // const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class _Biometric extends ConsumerWidget {
  const _Biometric();

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      showSnackbar(context, next.errorMessage);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centra el contenido en el eje vertical
        crossAxisAlignment:
            CrossAxisAlignment.center, // Centra en el eje horizontal
        children: [
          IconButton(
            icon: const Icon(Icons.fingerprint),
            onPressed: () => verificarHuella(context, ref),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              iconSize: 75,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 180,
            height: 60,
            child: CustomFilledButton(
              text: 'Usar credenciales',
              buttonColor: Colors.black,
              onPressed: () {
                ref
                    .read(biometricProvider.notifier)
                    .changeIsFingerprintEnabled(false);
              },
              radius: Radius.circular(30),
            ),
          ),
          // SizedBox(
          //   width: 180,
          //   height: 60,
          //   child: RichText(
          //     textAlign: TextAlign.center,
          //     text: TextSpan(
          //       text: 'Usar credenciales',
          //       style: const TextStyle(color: Colors.blue, fontSize: 16),
          //       recognizer: TapGestureRecognizer()
          //         ..onTap = () {
          //           print("faa");
          //         },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

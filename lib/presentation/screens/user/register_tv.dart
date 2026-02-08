part of '../screens.dart';

class RegisterUserTv extends StatefulWidget {
  const RegisterUserTv({super.key});

  @override
  State<RegisterUserTv> createState() => _RegisterUserTvState();
}

class _RegisterUserTvState extends State<RegisterUserTv> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _urlFocus = FocusNode();
  final FocusNode _btnFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: Row(
          children: [
            // Left Panel (Logo)
            Expanded(
              flex: 2,
              child: Container(
                color: kColorPanel,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(kIconSplash, width: 15.w),
                    const SizedBox(height: 20),
                    Text(
                      kAppName,
                      style: Get.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Login with Xtream Codes",
                      style: Get.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            // Right Panel (Form)
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Add User", style: Get.textTheme.headlineMedium),
                    const SizedBox(height: 30),
                    _buildTvInput(
                      controller: _usernameController,
                      label: "Username",
                      icon: Icons.person,
                      focus: _userFocus,
                      nextFocus: _passFocus,
                    ),
                    const SizedBox(height: 20),
                    _buildTvInput(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                      focus: _passFocus,
                      nextFocus: _urlFocus,
                    ),
                    const SizedBox(height: 20),
                    _buildTvInput(
                      controller: _urlController,
                      label: "http://url_here.com:port",
                      icon: Icons.link,
                      focus: _urlFocus,
                      nextFocus: _btnFocus,
                    ),
                    const SizedBox(height: 40),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                           Get.offAllNamed(screenWelcome);
                        } else if (state is AuthFailed) {
                           Get.snackbar("Login Failed", state.message, backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                      builder: (context, state) {
                         if (state is AuthLoading) {
                            return Center(child: LoadingAnimationWidget.staggeredDotsWave(color: kColorPrimary, size: 40));
                         }
                         return SizedBox(
                           width: double.infinity,
                           height: 60,
                           child: ElevatedButton(
                             focusNode: _btnFocus,
                             onPressed: () {
                               if (_usernameController.text.isNotEmpty && _passwordController.text.isNotEmpty && _urlController.text.isNotEmpty) {
                                  context.read<AuthBloc>().add(AuthLogin(
                                    _usernameController.text.trim(),
                                    _passwordController.text.trim(),
                                    _urlController.text.trim(),
                                  ));
                               }
                             },
                             style: ButtonStyle(
                               backgroundColor: MaterialStateProperty.resolveWith((states) {
                                 if (states.contains(MaterialState.focused)) return kColorFocus;
                                 return kColorPrimary;
                               }),
                             ),
                             child: const Text("LOGIN"),
                           ),
                         );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTvInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required FocusNode focus,
    FocusNode? nextFocus,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focus,
      obscureText: isPassword,
      onFieldSubmitted: (_) => nextFocus?.requestFocus(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: kColorCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kColorFocus, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

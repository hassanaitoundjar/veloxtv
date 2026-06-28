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
  final FocusNode _usersFocus = FocusNode();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();

    _userFocus.dispose();
    _passFocus.dispose();
    _urlFocus.dispose();
    _btnFocus.dispose();
    _usersFocus.dispose();
    super.dispose();
  }

  /// Handle D-Pad arrow keys to move focus between fields
  KeyEventResult _handleKeyEvent(
      KeyEvent event, FocusNode current, FocusNode? prev, FocusNode? next) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown && next != null) {
        next.requestFocus();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp && prev != null) {
        prev.requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void initState() {
    super.initState();
    _usersFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _userFocus.requestFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    _userFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _usersFocus.requestFocus();
        return KeyEventResult.handled;
      }
      return _handleKeyEvent(event, node, null, _passFocus);
    };
    
    _passFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _usersFocus.requestFocus();
        return KeyEventResult.handled;
      }
      return _handleKeyEvent(event, node, _userFocus, _urlFocus);
    };

    _urlFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _usersFocus.requestFocus();
        return KeyEventResult.handled;
      }
      return _handleKeyEvent(event, node, _passFocus, _btnFocus);
    };

    _btnFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _usersFocus.requestFocus();
        return KeyEventResult.handled;
      }
      return _handleKeyEvent(event, node, _urlFocus, null);
    };
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final isTvDevice = isTv(context);
    final isTvLayout = isLandscape || isTvDevice;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: !isTvLayout
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            )
          : null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: kDecorBackground,
        child: isTvLayout ? _buildTvLayout(context) : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildForm({bool isTvLayout = false}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Add User",
              style: Get.textTheme.headlineMedium, textAlign: TextAlign.center),
          if (!isTvLayout) ...[
            const SizedBox(height: 24),
            _buildUserListButton(),
          ],
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
                Get.offAllNamed(screenHome);
              } else if (state is AuthFailed) {
                Get.snackbar("Login Failed", state.message,
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                        color: kColorPrimary, size: 40));
              }
              return SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  focusNode: _btnFocus,
                  onPressed: () {
                    if (_usernameController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty &&
                        _urlController.text.isNotEmpty) {
                      context.read<AuthBloc>().add(AuthLogin(
                            _usernameController.text.trim(),
                            _passwordController.text.trim(),
                            _urlController.text.trim(),
                          ));
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.focused)) {
                        return kColorFocus;
                      }
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
    );
  }

  Widget _buildTvLayout(BuildContext context) {
    return Row(
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
                const SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: _buildUserListButton(),
                ),
              ],
            ),
          ),
        ),

        // Right Panel (Form)
        Expanded(
          flex: 3,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(
              left: 5.w,
              right: 5.w,
              top: 4.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 4.h,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: _buildForm(isTvLayout: true),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 40,
          bottom: MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: _buildForm(isTvLayout: false),
          ),
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
    return TvTextField(
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

  Widget _buildUserListButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        focusNode: _usersFocus,
        onPressed: () => Get.toNamed(screenProfiles),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: kColorPrimary, width: 2),
          foregroundColor: Colors.white,
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const BorderSide(color: kColorFocus, width: 2);
            }
            return const BorderSide(color: kColorPrimary, width: 2);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return kColorFocus;
            }
            return Colors.white;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return kColorFocus.withValues(alpha: 0.1);
            }
            return Colors.transparent;
          }),
        ),
        child: const Text("USER LIST",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

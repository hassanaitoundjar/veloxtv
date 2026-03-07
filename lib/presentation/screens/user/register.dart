part of '../screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _backFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();
  final _urlFocus = FocusNode();
  final _btnFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();

    _backFocus.dispose();
    _nameFocus.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    _urlFocus.dispose();
    _btnFocus.dispose();
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
    // Back button wiring
    _backFocus.onKeyEvent = (node, event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
            event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _nameFocus.requestFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    _nameFocus.onKeyEvent =
        (node, event) => _handleKeyEvent(event, node, _backFocus, _userFocus);
    _userFocus.onKeyEvent =
        (node, event) => _handleKeyEvent(event, node, _nameFocus, _passFocus);
    _passFocus.onKeyEvent =
        (node, event) => _handleKeyEvent(event, node, _userFocus, _urlFocus);
    _urlFocus.onKeyEvent =
        (node, event) => _handleKeyEvent(event, node, _passFocus, _btnFocus);
    _btnFocus.onKeyEvent =
        (node, event) => _handleKeyEvent(event, node, _urlFocus, null);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    final isTvDevice = isTv(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          focusNode: _backFocus,
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
          color: _backFocus.hasFocus ? kColorFocus : Colors.white,
        ),
      ),
      body: Container(
        width: 100.w,
        height: 100.h,
        decoration: kDecorBackground,
        child: isLandscape || isTvDevice
            ? _buildTvLayout(context)
            : _buildMobileLayout(context),
      ),
    );
  }

  Widget _buildForm({bool isTvLayout = false}) {
    return Form(
      key: _formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isTvLayout
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.stretch,
          children: [
            if (isTvLayout)
              Text("Add User",
                  style: Get.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            if (!isTvLayout) ...[
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.api, color: kColorPrimary, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Text("Xtream Codes",
                  style: Get.textTheme.headlineLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("Login with your Xtream Codes credentials",
                  style: Get.textTheme.bodyMedium
                      ?.copyWith(color: kColorTextSecondary),
                  textAlign: TextAlign.center),
            ],
            SizedBox(height: isTvLayout ? 4.h : 40),
            _buildTvInput(
              controller: _nameController,
              label: "Any Name",
              hint: "e.g. My IPTV",
              icon: Icons.person_outline,
              focusNode: _nameFocus,
              nextFocus: _userFocus,
              autofocus: isTvLayout,
            ),
            SizedBox(height: isTvLayout ? 2.h : 16),
            _buildTvInput(
              controller: _usernameController,
              label: "Username",
              hint: "Enter username",
              icon: Icons.account_circle_outlined,
              focusNode: _userFocus,
              nextFocus: _passFocus,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: isTvLayout ? 2.h : 16),
            _buildTvInput(
              controller: _passwordController,
              label: "Password",
              hint: "Enter password",
              icon: Icons.lock_outline,
              focusNode: _passFocus,
              nextFocus: _urlFocus,
              obscure: true,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: isTvLayout ? 2.h : 16),
            _buildTvInput(
              controller: _urlController,
              label: "Server URL",
              hint: "http://url_here.com:port",
              icon: Icons.link,
              focusNode: _urlFocus,
              nextFocus: _btnFocus,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: isTvLayout ? 4.h : 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTvLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: kColorPrimary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.api, color: kColorPrimary, size: 50),
                ),
                const SizedBox(height: 24),
                Text(kAppName,
                    style: Get.textTheme.headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Login with Xtream Codes",
                    style: Get.textTheme.bodyLarge
                        ?.copyWith(color: kColorPrimary)),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
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
      child: Padding(
        padding: const EdgeInsets.all(24),
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
    required String hint,
    required IconData icon,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
    bool autofocus = false,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: kColorCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kColorFocus, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textInputAction:
          nextFocus != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          nextFocus.requestFocus();
        }
      },
      validator: validator,
      maxLines: 1,
    );
  }

  Widget _buildSubmitButton() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Get.offAllNamed(screenHome);
        } else if (state is AuthFailed) {
          Get.snackbar("Error", state.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white);
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: kColorPrimary,
              size: 40,
            ),
          );
        }
        return SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            focusNode: _btnFocus,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<AuthBloc>().add(AuthLogin(
                      _usernameController.text.trim(),
                      _passwordController.text.trim(),
                      _urlController.text.trim(),
                    ));
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.focused)) return kColorFocus;
                return kColorPrimary;
              }),
            ),
            child: const Text("LOGIN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

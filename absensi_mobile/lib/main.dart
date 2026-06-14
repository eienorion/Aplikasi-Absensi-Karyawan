import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const AbsensiApp());
}

// ============================================================
// CONSTANTS
// ============================================================

class AppColors {
  static const Color bgDark = Color(0xFF0A0F1E);
  static const Color surfaceDark = Color(0xFF0D1328);
  static const Color accent = Color(0xFF2D6BE4);
  static const Color accentLight = Color(0xFF5B8FEF);
  static const Color inputBg = Color(0x0DFFFFFF);
  static const Color inputBorder = Color(0x1AFFFFFF);
  static const Color cardBorder = Color(0x14FFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0x59FFFFFF);
  static const Color textHint = Color(0x33FFFFFF);
  static const Color green = Color(0xFF3CC99A);
  static const Color greenBg = Color(0x1A3CC99A);
  static const Color greenBorder = Color(0x333CC99A);
  static const Color amber = Color(0xFFF4B347);
  static const Color amberBg = Color(0x1AF4B347);
  static const Color amberBorder = Color(0x33F4B347);
  static const Color blue = Color(0xFF5B8FEF);
  static const Color blueBg = Color(0x1A5B8FEF);
  static const Color blueBorder = Color(0x335B8FEF);
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData prefixIcon,
  Widget? suffix,
}) {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.inputBg,
    hoverColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(
      color: AppColors.textHint,
      fontSize: 14,
    ),
    prefixIcon: Icon(prefixIcon, color: const Color(0x40FFFFFF), size: 18),
    suffixIcon: suffix,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.accent, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent, width: 0.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1),
    ),
  );
}

TextStyle _fieldLabelStyle() => GoogleFonts.plusJakartaSans(
  fontSize: 10,
  fontWeight: FontWeight.w600,
  color: AppColors.textMuted,
  letterSpacing: 0.8,
);

// ============================================================
// API SERVICE
// ============================================================

class ApiService {
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api';

  static Future<String> getBaseUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('base_url') ?? defaultBaseUrl;
  }

  static Future<void> saveBaseUrl(String url) async {
    String cleanedUrl = url.trim();

    while (cleanedUrl.endsWith('/')) {
      cleanedUrl = cleanedUrl.substring(0, cleanedUrl.length - 1);
    }

    if (!cleanedUrl.endsWith('/api')) {
      cleanedUrl = '$cleanedUrl/api';
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('base_url', cleanedUrl);
  }

  static Future<void> resetBaseUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('base_url');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final String baseUrl = await getBaseUrl();
    final Uri url = Uri.parse('$baseUrl/register');

    final http.Response response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    return _handleJsonResponse(response);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final String baseUrl = await getBaseUrl();
    final Uri url = Uri.parse('$baseUrl/login');

    final http.Response response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleJsonResponse(response);
  }

  static Future<Map<String, dynamic>> submitAttendance({
    required int userId,
    required String attendanceType,
    required double latitude,
    required double longitude,
    Uint8List? photoBytes,
  }) async {
    final String baseUrl = await getBaseUrl();
    final Uri url = Uri.parse('$baseUrl/attendances');

    final http.MultipartRequest request = http.MultipartRequest('POST', url);

    request.headers.addAll({'Accept': 'application/json'});

    request.fields['user_id'] = userId.toString();
    request.fields['attendance_type'] = attendanceType;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    if (photoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: 'attendance_${DateTime.now().millisecondsSinceEpoch}.png',
          contentType: MediaType('image', 'png'),
        ),
      );
    }

    final http.StreamedResponse streamedResponse = await request.send();
    final String responseBody = await streamedResponse.stream.bytesToString();

    return _handleStringResponse(
      statusCode: streamedResponse.statusCode,
      body: responseBody,
    );
  }

  static Future<List<Map<String, dynamic>>> getAttendances({
    int? month,
    int? year,
  }) async {
    final String baseUrl = await getBaseUrl();
    String endpoint = '$baseUrl/attendances';

    final Map<String, String> query = {};

    if (month != null) {
      query['month'] = month.toString();
    }

    if (year != null) {
      query['year'] = year.toString();
    }

    if (query.isNotEmpty) {
      endpoint = Uri.parse(endpoint).replace(queryParameters: query).toString();
    }

    final http.Response response = await http.get(
      Uri.parse(endpoint),
      headers: {'Accept': 'application/json'},
    );

    final Map<String, dynamic> data = _handleJsonResponse(response);
    final List<dynamic> records = data['data'] ?? [];

    return records.map((item) => item as Map<String, dynamic>).toList();
  }

  static Future<Map<String, dynamic>> getSummary() async {
    final String baseUrl = await getBaseUrl();

    final http.Response response = await http.get(
      Uri.parse('$baseUrl/attendances/summary'),
      headers: {'Accept': 'application/json'},
    );

    return _handleJsonResponse(response);
  }

  static Map<String, dynamic> _handleJsonResponse(http.Response response) {
    return _handleStringResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  static Map<String, dynamic> _handleStringResponse({
    required int statusCode,
    required String body,
  }) {
    final Map<String, dynamic> data = body.isNotEmpty
        ? jsonDecode(body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    String message = data['message']?.toString() ?? 'Terjadi kesalahan';

    if (data['errors'] != null) {
      final Map<String, dynamic> errors =
          data['errors'] as Map<String, dynamic>;
      final List<String> errorMessages = [];

      errors.forEach((key, value) {
        if (value is List) {
          errorMessages.addAll(value.map((item) => item.toString()));
        } else {
          errorMessages.add(value.toString());
        }
      });

      if (errorMessages.isNotEmpty) {
        message = errorMessages.join('\n');
      }
    }

    throw Exception(message);
  }
}

// ============================================================
// APP
// ============================================================

class AbsensiApp extends StatelessWidget {
  const AbsensiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Absensi Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  Future<void> showServerSettingDialog() async {
    final String currentUrl = await ApiService.getBaseUrl();
    final TextEditingController serverController = TextEditingController(
      text: currentUrl,
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Pengaturan Server'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan URL server backend Laravel.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: serverController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL Server',
                  hintText: 'https://xxxx.trycloudflare.com/api',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika tidak menulis /api, aplikasi akan menambahkannya otomatis.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await ApiService.resetBaseUrl();

                if (!dialogContext.mounted || !mounted) return;

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL server dikembalikan ke default'),
                  ),
                );
              },
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () async {
                final String inputUrl = serverController.text.trim();

                if (inputUrl.isEmpty) {
                  return;
                }

                if (!inputUrl.startsWith('http://') &&
                    !inputUrl.startsWith('https://')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL harus diawali http:// atau https://'),
                    ),
                  );
                  return;
                }

                await ApiService.saveBaseUrl(inputUrl);

                if (!dialogContext.mounted || !mounted) return;

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URL server berhasil disimpan')),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    serverController.dispose();
  }

  bool _obscurePassword = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.login(email: email, password: password);
      final user = response['user'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt('user_id', user['id'] as int);
      await prefs.setString('user_name', user['name'].toString());
      await prefs.setString('user_email', user['email'].toString());
      await prefs.setString('user_role', user['role'].toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeHomeScreen(
            employeeId: user['id'] as int,
            employeeName: user['name'].toString(),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 52),

                  // Brand
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.medication_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apotek Bunut',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Sistem Absensi Karyawan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 52),

                  // Heading
                  Text(
                    'SELAMAT DATANG',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Masuk ke akun\nAnda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.15,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Absensi hanya dapat dilakukan\ndari perangkat terdaftar.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Email
                  Text('EMAIL', style: _fieldLabelStyle()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      hint: 'nama@apotekbunut.com',
                      prefixIcon: Icons.mail_outline_rounded,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Password
                  Text('KATA SANDI', style: _fieldLabelStyle()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration(
                      hint: 'Masukkan kata sandi',
                      prefixIcon: Icons.lock_outline_rounded,
                      suffix: GestureDetector(
                        onTap: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        child: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0x40FFFFFF),
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Lupa sandi
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Lupa kata sandi?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Tombol masuk
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        disabledBackgroundColor: const Color(0xFF1A3A7A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Masuk',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                    ),
                  ),

                  const Spacer(),

                  // Register row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: GestureDetector(
                        onTap: goToRegister,
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            children: [
                              const TextSpan(text: 'Belum punya akun? '),
                              TextSpan(
                                text: 'Register',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Server setting row
                  Center(
                    child: GestureDetector(
                      onTap: showServerSettingDialog,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pengaturan Server',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER SCREEN
// ============================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, email, dan password wajib diisi')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.register(name: name, email: email, password: password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil, silakan login')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Custom back header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Buat Akun',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    Text(
                      'DAFTAR AKUN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Buat akun\nkaryawan baru',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Akun akan digunakan untuk login\ndan mencatat absensi harian.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Nama
                    Text('NAMA LENGKAP', style: _fieldLabelStyle()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Masukkan nama lengkap',
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email
                    Text('EMAIL', style: _fieldLabelStyle()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'nama@apotekbunut.com',
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password
                    Text('KATA SANDI', style: _fieldLabelStyle()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        hint: 'Buat kata sandi',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffix: GestureDetector(
                          onTap: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0x40FFFFFF),
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol register
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          disabledBackgroundColor: const Color(0xFF1A3A7A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Buat Akun',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Back to login
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            children: [
                              const TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(
                                text: 'Masuk',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accentLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPLOYEE HOME SCREEN
// ============================================================

class EmployeeHomeScreen extends StatelessWidget {
  final int employeeId;
  final String employeeName;

  const EmployeeHomeScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
  });

  void logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());
    final timeNow = DateFormat('HH:mm', 'id_ID').format(DateTime.now());
    final hour = DateTime.now().hour;

    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
        ? 'Selamat siang'
        : hour < 18
        ? 'Selamat sore'
        : 'Selamat malam';

    final parts = employeeName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : employeeName.substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cardBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.medication_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Apotek Bunut',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => logout(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A7A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.accent, width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        employeeName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Date + time banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          today,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeNow,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.greenBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.greenBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Operasional',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: AppColors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Section label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'MENU ABSENSI',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _HomeMenuCard(
                      icon: Icons.login_rounded,
                      iconColor: AppColors.green,
                      iconBg: AppColors.greenBg,
                      iconBorder: AppColors.greenBorder,
                      title: 'Absensi Masuk',
                      subtitle: 'Selfie + lokasi saat mulai kerja',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
                            employeeId: employeeId,
                            employeeName: employeeName,
                            attendanceType: 'Masuk',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _HomeMenuCard(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.amber,
                      iconBg: AppColors.amberBg,
                      iconBorder: AppColors.amberBorder,
                      title: 'Absensi Pulang',
                      subtitle: 'Selfie + lokasi saat selesai kerja',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceScreen(
                            employeeId: employeeId,
                            employeeName: employeeName,
                            attendanceType: 'Pulang',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _HomeMenuCard(
                      icon: Icons.history_rounded,
                      iconColor: AppColors.blue,
                      iconBg: AppColors.blueBg,
                      iconBorder: AppColors.blueBorder,
                      title: 'Riwayat Absensi',
                      subtitle: 'Lihat catatan absensi pribadi',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur riwayat akan dibuat berikutnya'),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Apotek Bunut • Sistem Absensi v1.0',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0x26FFFFFF),
                        ),
                      ),
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
}

class _HomeMenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeMenuCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconBorder, width: 0.5),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0x33FFFFFF),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUCCESS INFO ROW (dipakai di AttendanceScreen)
// ============================================================

class _SuccessInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SuccessInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ATTENDANCE SCREEN (tidak diubah dari original)
// ============================================================

class AttendanceScreen extends StatefulWidget {
  final int employeeId;
  final String attendanceType;
  final String employeeName;

  const AttendanceScreen({
    super.key,
    required this.employeeId,
    required this.attendanceType,
    required this.employeeName,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  XFile? selectedImage;
  Uint8List? selectedImageBytes;
  Position? currentPosition;

  bool isLoadingLocation = false;
  bool isSubmitting = false;

  // ---- LOGIC TIDAK DIUBAH ----

  Future<void> showAttendanceSuccessDialog({
    required String attendanceType,
    required String date,
    required String time,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.greenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Absensi Berhasil',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Data absensi $attendanceType kamu berhasil disimpan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0x0AFFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: Column(
                  children: [
                    _DarkInfoRow(
                      icon: Icons.assignment_turned_in_rounded,
                      iconColor: AppColors.blue,
                      iconBg: AppColors.blueBg,
                      label: 'Jenis Absensi',
                      value: attendanceType,
                    ),
                    const SizedBox(height: 10),
                    _DarkInfoRow(
                      icon: Icons.calendar_today_rounded,
                      iconColor: AppColors.amber,
                      iconBg: AppColors.amberBg,
                      label: 'Tanggal',
                      value: date,
                    ),
                    const SizedBox(height: 10),
                    _DarkInfoRow(
                      icon: Icons.access_time_rounded,
                      iconColor: AppColors.green,
                      iconBg: AppColors.greenBg,
                      label: 'Waktu',
                      value: time,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> takeSelfie() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Layanan lokasi belum aktif');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak permanen');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() => currentPosition = position);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() => isLoadingLocation = false);
    }
  }

  String get watermarkText {
    final dateTime = DateFormat(
      'dd-MM-yyyy HH:mm:ss',
      'id_ID',
    ).format(DateTime.now());
    if (currentPosition == null) {
      return '${widget.employeeName}\n'
          'Absensi ${widget.attendanceType} • $dateTime\n'
          'Lokasi belum diambil';
    }
    return '${widget.employeeName}\n'
        'Absensi ${widget.attendanceType} • $dateTime\n'
        'Lat: ${currentPosition!.latitude.toStringAsFixed(6)}, '
        'Lng: ${currentPosition!.longitude.toStringAsFixed(6)}';
  }

  Future<void> submitAttendance() async {
    if (selectedImage == null || selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan ambil foto selfie terlebih dahulu'),
        ),
      );
      return;
    }
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil lokasi terlebih dahulu')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final capturedImage = await screenshotController.capture(pixelRatio: 2);
      if (capturedImage == null) {
        throw Exception('Gagal memproses foto absensi');
      }

      await ApiService.submitAttendance(
        userId: widget.employeeId,
        attendanceType: widget.attendanceType,
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        photoBytes: capturedImage,
      );

      final time = DateFormat('HH:mm:ss').format(DateTime.now());
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await showAttendanceSuccessDialog(
        attendanceType: widget.attendanceType,
        date: date,
        time: time,
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  // ---- BUILD (REDESIGNED) ----

  Color get _typeAccentColor =>
      widget.attendanceType == 'Masuk' ? AppColors.green : AppColors.amber;

  Color get _typeAccentBg =>
      widget.attendanceType == 'Masuk' ? AppColors.greenBg : AppColors.amberBg;

  Color get _typeAccentBorder => widget.attendanceType == 'Masuk'
      ? AppColors.greenBorder
      : AppColors.amberBorder;

  IconData get _typeIcon => widget.attendanceType == 'Masuk'
      ? Icons.login_rounded
      : Icons.logout_rounded;

  Widget _buildPhotoArea() {
    if (selectedImageBytes == null) {
      return GestureDetector(
        onTap: takeSelfie,
        child: Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0x0AFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 0.5),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0x40FFFFFF),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap untuk mengambil selfie',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pastikan wajah terlihat jelas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0x33FFFFFF),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: takeSelfie,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 240,
          child: Screenshot(
            controller: screenshotController,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(selectedImageBytes!, fit: BoxFit.cover),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black.withOpacity(0.70),
                    child: Text(
                      watermarkText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                // Retake badge
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Ulangi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    final now = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ---- CUSTOM APP BAR ----
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _typeAccentBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _typeAccentBorder, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(_typeIcon, size: 12, color: _typeAccentColor),
                        const SizedBox(width: 5),
                        Text(
                          'Absensi ${widget.attendanceType}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: _typeAccentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- INFO BANNER ----
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.cardBorder,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _typeAccentBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _typeAccentBorder,
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              _typeIcon,
                              color: _typeAccentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.employeeName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                now,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---- SECTION: FOTO ----
                    Text(
                      'FOTO SELFIE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPhotoArea(),

                    const SizedBox(height: 20),

                    // ---- SECTION: LOKASI ----
                    Text(
                      'LOKASI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tombol ambil lokasi
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: isLoadingLocation
                            ? null
                            : getCurrentLocation,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: currentPosition != null
                              ? AppColors.green
                              : AppColors.textMuted,
                          side: BorderSide(
                            color: currentPosition != null
                                ? AppColors.greenBorder
                                : AppColors.cardBorder,
                            width: 0.5,
                          ),
                          backgroundColor: currentPosition != null
                              ? AppColors.greenBg
                              : AppColors.surfaceDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: isLoadingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textMuted,
                                ),
                              )
                            : Icon(
                                currentPosition != null
                                    ? Icons.my_location_rounded
                                    : Icons.location_on_outlined,
                                size: 18,
                              ),
                        label: Text(
                          isLoadingLocation
                              ? 'Mengambil lokasi...'
                              : currentPosition != null
                              ? 'Lokasi berhasil diambil'
                              : 'Ambil Lokasi Saat Ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Koordinat (muncul jika lokasi sudah diambil)
                    if (currentPosition != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x0A3CC99A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.greenBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_pin,
                              size: 14,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lat: ${currentPosition!.latitude.toStringAsFixed(6)}  '
                                'Lng: ${currentPosition!.longitude.toStringAsFixed(6)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ---- TOMBOL SUBMIT ----
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : submitAttendance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _typeAccentColor,
                          disabledBackgroundColor: _typeAccentColor.withOpacity(
                            0.3,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                              ),
                        label: Text(
                          isSubmitting
                              ? 'Menyimpan...'
                              : 'Submit Absensi ${widget.attendanceType}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
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
}

// ---- DARK INFO ROW (dipakai di success dialog) ----

class _DarkInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  const _DarkInfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

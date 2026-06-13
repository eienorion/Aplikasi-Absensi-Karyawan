import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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

class ApiService {
  // Untuk Android Emulator gunakan 10.0.2.2.
  // Kalau menjalankan Flutter di Chrome, ganti menjadi: http://127.0.0.1:8000/api
  // Kalau menjalankan di HP asli, ganti menjadi IP laptop, contoh: http://192.168.1.10:8000/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> response = await ApiService.login(
        email: email,
        password: password,
      );

      final Map<String, dynamic> user =
          response['user'] as Map<String, dynamic>;

      final SharedPreferences prefs = await SharedPreferences.getInstance();

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
      setState(() {
        isLoading = false;
      });
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 90,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Absensi Mobile',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login untuk melanjutkan',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: isLoading ? null : login,
                      child: Text(isLoading ? 'Loading...' : 'Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: goToRegister,
                    child: const Text('Belum punya akun? Register'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin dummy: admin@gmail.com / admin123',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama, email, dan password wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Karyawan')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 80,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Buat Akun Karyawan',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: isLoading ? null : register,
                      child: Text(isLoading ? 'Menyimpan...' : 'Register'),
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
    final String today = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Karyawan'),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $employeeName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(today),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.login, color: Colors.green),
                  title: const Text('Absensi Masuk'),
                  subtitle: const Text(
                    'Ambil selfie dan lokasi saat masuk kerja',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceScreen(
                          employeeId: employeeId,
                          employeeName: employeeName,
                          attendanceType: 'Masuk',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orange),
                  title: const Text('Absensi Pulang'),
                  subtitle: const Text(
                    'Ambil selfie dan lokasi saat pulang kerja',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceScreen(
                          employeeId: employeeId,
                          employeeName: employeeName,
                          attendanceType: 'Pulang',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Riwayat Absensi'),
                  subtitle: const Text('Lihat riwayat absensi pribadi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur riwayat akan dibuat berikutnya'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

  Future<void> takeSelfie() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      final Uint8List bytes = await image.readAsBytes();

      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Layanan lokasi belum aktif');
      }

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

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  String get watermarkText {
    final String dateTime = DateFormat(
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

    setState(() {
      isSubmitting = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final Uint8List? capturedImage = await screenshotController.capture(
        pixelRatio: 2,
      );

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

      final String time = DateFormat('HH:mm:ss').format(DateTime.now());
      final String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Absensi ${widget.attendanceType} berhasil pada $date $time',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Widget buildPhotoPreview() {
    if (selectedImageBytes == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap untuk mengambil selfie'),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String now = DateFormat(
      'dd MMMM yyyy, HH:mm',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: Text('Absensi ${widget.attendanceType}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 48,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        now,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Nama: ${widget.employeeName}'),
                      Text('Jenis absensi: ${widget.attendanceType}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: takeSelfie,
                child: Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey.shade100,
                  ),
                  child: buildPhotoPreview(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: isLoadingLocation ? null : getCurrentLocation,
                  icon: const Icon(Icons.location_on_outlined),
                  label: Text(
                    isLoadingLocation
                        ? 'Mengambil lokasi...'
                        : 'Ambil Lokasi Saat Ini',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (currentPosition != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.my_location, color: Colors.green),
                    title: const Text('Lokasi berhasil diambil'),
                    subtitle: Text(
                      'Lat: ${currentPosition!.latitude}\n'
                      'Lng: ${currentPosition!.longitude}',
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : submitAttendance,
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(isSubmitting ? 'Menyimpan...' : 'Submit Absensi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

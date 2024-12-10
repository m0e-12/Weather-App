import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost:5050/register'), // Make sure this is correct
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (!mounted) return;

    if (response.statusCode == 201) {
      developer.log('User registered successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User registered successfully!')),
      );
    } else {
      developer.log('Error registering user: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error registering user!')),
      );
    }
  }

  void handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both username and password')),
        );
      }
      return;
    }

    final userId = 1; // This should be dynamic after successful registration

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WeatherScreen(userId: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text('Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final username = usernameController.text.trim();
                final password = passwordController.text.trim();
                if (username.isNotEmpty && password.isNotEmpty) {
                  registerUser(username, password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a username and password')),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final int userId;

  const WeatherScreen({required this.userId, super.key});

  @override
  WeatherScreenState createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:5050/weather';
  Map<String, dynamic>? weatherData;
  TextEditingController cityController = TextEditingController();

  Future<void> saveWeatherData(Map<String, dynamic> weatherData) async {
    final response = await http.post(
      Uri.parse('http://localhost:5050/weather/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': widget.userId,
        'city': weatherData['city'],
        'temperature': weatherData['temperature'],
        'description': weatherData['description'],
        'humidity': weatherData['humidity'],
        'wind_speed': weatherData['wind_speed'],
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 201) {
      developer.log('Weather data saved successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weather data saved successfully!')),
      );
    } else {
      developer.log('Error saving weather data: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving weather data!')),
      );
    }
  }

  void fetchWeather(String city) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?city=$city'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          weatherData = data;
        });

        await saveWeatherData(weatherData!);
      } else {
        developer.log('Error fetching weather: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching weather: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Enter City',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (cityController.text.isNotEmpty) {
                  fetchWeather(cityController.text.trim());
                }
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 32),
            weatherData == null
                ? const Center(child: Text('Enter a city to get weather details'))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("City: ${weatherData!['city']}"),
                      Text("Temperature: ${weatherData!['temperature']}°C"),
                      Text("Description: ${weatherData!['description']}"),
                      Text("Humidity: ${weatherData!['humidity']}%"),
                      Text("Wind Speed: ${weatherData!['wind_speed']} m/s"),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:developer' as developer;

// void main() async {
//   await dotenv.load(fileName: "assets/.env");
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const LoginScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   LoginScreenState createState() => LoginScreenState();
// }

// class LoginScreenState extends State<LoginScreen> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   Future<void> registerUser(String username, String password) async {
//     final response = await http.post(
//       Uri.parse('http://localhost:5050/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'username': username, 'password': password}),
//     );

//     if (!mounted) return;

//     if (response.statusCode == 201) {
//       developer.log('User registered successfully');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('User registered successfully!')),
//       );
//     } else {
//       developer.log('Error registering user: ${response.body}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error registering user!')),
//       );
//     }
//   }

//   void handleLogin() async {
//     final username = usernameController.text.trim();
//     final password = passwordController.text.trim();

//     if (username.isEmpty || password.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter both username and password')),
//         );
//       }
//       return;
//     }


//     final userId = 1; 

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => WeatherScreen(userId: userId)),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: usernameController,
//               decoration: const InputDecoration(
//                 labelText: 'Username',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: handleLogin,
//               child: const Text('Login'),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 registerUser(
//                   usernameController.text.trim(),
//                   passwordController.text.trim(),
//                 );
//               },
//               child: const Text('Register'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class WeatherScreen extends StatefulWidget {
//   final int userId;

//   const WeatherScreen({required this.userId, super.key});

//   @override
//   WeatherScreenState createState() => WeatherScreenState();
// }

// class WeatherScreenState extends State<WeatherScreen> {
//   final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:5050/weather';
//   Map<String, dynamic>? weatherData;
//   TextEditingController cityController = TextEditingController();

//   Future<void> saveWeatherData(Map<String, dynamic> weatherData) async {
//     final response = await http.post(
//       Uri.parse('http://localhost:5050/weather/save'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'userId': widget.userId,
//         'city': weatherData['city'],
//         'temperature': weatherData['temperature'],
//         'description': weatherData['description'],
//         'humidity': weatherData['humidity'],
//         'wind_speed': weatherData['wind_speed'],
//       }),
//     );

//     if (!mounted) return;

//     if (response.statusCode == 201) {
//       developer.log('Weather data saved successfully');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Weather data saved successfully!')),
//       );
//     } else {
//       developer.log('Error saving weather data: ${response.body}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error saving weather data!')),
//       );
//     }
//   }

//   void fetchWeather(String city) async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl?city=$city'));

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         setState(() {
//           weatherData = data;
//         });

//         await saveWeatherData(weatherData!);
//       } else {
//         developer.log('Error fetching weather: ${response.statusCode}');
//       }
//     } catch (e) {
//       developer.log('Error fetching weather: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Weather App'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: cityController,
//               decoration: const InputDecoration(
//                 labelText: 'Enter City',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 if (cityController.text.isNotEmpty) {
//                   fetchWeather(cityController.text.trim());
//                 }
//               },
//               child: const Text('Get Weather'),
//             ),
//             const SizedBox(height: 32),
//             weatherData == null
//                 ? const Center(child: Text('Enter a city to get weather details'))
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("City: ${weatherData!['city']}"),
//                       Text("Temperature: ${weatherData!['temperature']}°C"),
//                       Text("Description: ${weatherData!['description']}"),
//                       Text("Humidity: ${weatherData!['humidity']}%"),
//                       Text("Wind Speed: ${weatherData!['wind_speed']} m/s"),
//                     ],
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }











import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({Key? key}) : super(key: key);

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late Future<Map<String, dynamic>> _forecastData;

  @override
  void initState() {
    super.initState();
    _forecastData = fetchForecast();
  }

  Future<Map<String, dynamic>> fetchForecast() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final apiKey = '9697864bfb8b18741a229ec2d35a6811';
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3-Day Forecast'),
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _forecastData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final forecastData = snapshot.data!['list'].sublist(0, 3);

              return ListView.builder(
                itemCount: forecastData.length,
                itemBuilder: (context, index) {
                  final dayData = forecastData[index];
                  final tempMin = dayData['main']['temp_min'];
                  final tempMax = dayData['main']['temp_max'];
                  final description = dayData['weather'][0]['description'];
                  final icon = dayData['weather'][0]['icon'];

                  return ListTile(
                    leading: Image.network(
                        'https://openweathermap.org/img/w/$icon.png'),
                    title: Text(
                        'Min: $tempMin°C, Max: $tempMax°C, $description'),
                  );
                },
              );
            } else {
              return const Text('No data available');
            }
          },
        ),
      ),
    );
  }
}

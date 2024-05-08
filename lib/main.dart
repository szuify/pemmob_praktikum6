import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

// class untuk merepresentasikan data universitas
class University {
  String name; // nama universitas
  String website; // website universitas

  University(
      {required this.name,
      required this.website}); //konstruktor untuk objek University

  // Method untuk membuat objek University dari data JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], //mengambil nama dari JSON
      website: json['web_pages'][0], //mengambil situs web pertama dari JSON
    );
  }
}

void main() {
  // Memulai aplikasi dengan Provider untuk state management
  runApp(
    ChangeNotifierProvider<UniversityModel>(
      create: (context) =>
          UniversityModel(), //membuat instance dari UniversityModel
      child: const MyApp(), // menjalankan aplikasi utama
    ),
  );
}

// class untuk mengelola state aplikasi tentang data universitas dan negara ASEAN
class UniversityModel extends ChangeNotifier {
  late List<University> universities; // List universitas
  late String selectedCountry; // Negara yang dipilih
  final String baseUrl = "http://universities.hipolabs.com"; //URL dasar API

  UniversityModel() {
    universities = []; //inisialisasi list universitas
    selectedCountry = "Indonesia"; // negara yang dipilih secara default
    fetchData(selectedCountry); // mengambil data universitas berdasarkan negara
  }

  // Method untuk mengambil data universitas berdasarkan negara dari API
  void fetchData(String country) async {
    final response =
        await http.get(Uri.parse("$baseUrl/search?country=$country"));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      universities = data
          .map((university) => University.fromJson(university))
          .toList(); // mengisi list universitas dari JSON
      notifyListeners(); // mengirim info bahwa data telah diupdate
    } else {
      throw Exception('Gagal load'); // throw error jika gagal mengambil data
    }
  }

  // Method untuk mengubah negara terpilih dan mengambil data universitas baru
  void setSelectedCountry(String country) {
    selectedCountry = country; // mengubah negara yang terpilih
    fetchData(selectedCountry); // mengambil data baru
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var universityModel = Provider.of<UniversityModel>(
        context); // mengambil instance dari UniversityModel

    return MaterialApp(
      title: 'Universitas',
      home: Scaffold(
        appBar: AppBar(
          title: Text('List Universitas'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dropdown button untuk memilih negara ASEAN
              DropdownButton<String>(
                value: universityModel
                    .selectedCountry, // nilai yang dipilih pada dropdown
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    universityModel.setSelectedCountry(
                        newValue); // mengubah negara terpilih saat dropdown diubah
                  }
                },
                items: <String>[
                  // List item untuk dropdown berisi negara-negara ASEAN
                  'Indonesia',
                  'Malaysia',
                  'Singapore',
                  'Thailand',
                  'Vietnam',
                  'Myanmar',
                  'Cambodia',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value), // menampilkan nama negara pada dropdown
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: universityModel
                      .universities.length, // jumlah item pada list universitas
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            // Nama universitas
                            Center(
                              child: Text(
                                universityModel.universities[index]
                                    .name, // menampilkan nama universitas
                                style: TextStyle(
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            // Website universitas
                            Center(
                              child: Text(
                                universityModel.universities[index]
                                    .website, // menampilkan website universitas
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
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

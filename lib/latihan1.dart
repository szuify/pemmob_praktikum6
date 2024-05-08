import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

// class untuk representasi data universitas
class UniversityModel {
  String name; // nama universitas
  String website; // website universitas

  UniversityModel(
      {required this.name,
      required this.website}); // Constructor untuk inisialisasi objek UniversityModel

  // method untuk mengonversi data JSON ke objek UniversityModel
  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

class UniversityCubit extends Cubit<List<UniversityModel>> {
  // Cubit untuk mengelola data universitas
  UniversityCubit()
      : super([]); // Constructor untuk inisialisasi data universitas kosong

  // Method untuk mengambil data universitas dari API berdasarkan negara
  void fetchData(String country) async {
    String url =
        "http://universities.hipolabs.com/search?country=$country"; // URL dasar API
    final response = await http.get(Uri.parse(
        url)); // Melakukan HTTP GET request untuk mendapatkan data dari API

    if (response.statusCode == 200) {
      // Jika response status code adalah 200, maka (OK)
      List<dynamic> data =
          jsonDecode(response.body); // Dekode data JSON menjadi List<dynamic>
      List<UniversityModel> universities = [];

      data.forEach((university) {
        // Looping untuk setiap data universitas
        universities.add(UniversityModel.fromJson(
            university)); // Menambahkan objek UniversityModel ke dalam List universities
      });

      emit(universities); // mengirimkan data universities ke listeners
    } else {
      throw Exception(
          'Gagal load'); // throw exception jika gagal melakukan load data
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universities',
      home: BlocProvider(
        // membungkus halaman utama dengan BlocProvider untuk menyediakan UniversityCubit ke widget tree
        create: (_) =>
            UniversityCubit(), // membuat instance dari UniversityCubit
        child: HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  _HalamanUtamaState createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late UniversityCubit
      universityCubit; // instance UniversityCubit untuk mengakses data universitas
  String selectedCountry =
      'Indonesia'; // nilai default dropdown diatur ke 'Indonesia' untuk tampilan awal

  @override
  void initState() {
    super.initState();
    universityCubit = BlocProvider.of<UniversityCubit>(
        context); // mendapatkan instance UniversityCubit dari BlocProvider
    universityCubit.fetchData(
        selectedCountry); // memanggil fetchData untuk mengambil data universitas berdasarkan negara
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar sebagai header aplikasi
        title: Text(
            'List Universitas - $selectedCountry'), // Judul dropdown dengan negara yang dipilih
      ),
      body: Center(
        // widget Center untuk membuat konten berada di tengah layar
        child: Column(
          // widget Column untuk menampung elemen secara vertikal
          mainAxisAlignment: MainAxisAlignment
              .center, // mengatur elemen secara vertikal di tengah layar
          children: [
            // list children untuk menampung widget-widget di dalam Column
            DropdownButton<String>(
              // widget DropdownButton untuk menampilkan dropdown negara
              value: selectedCountry, // nilai dropdown sesuai negara terpilih
              onChanged: (String? newValue) {
                // method yang dipanggil saat dropdown diubah
                if (newValue != null) {
                  // Jika nilai baru tidak null
                  setState(() {
                    // memanggil setState untuk memperbarui tampilan UI
                    selectedCountry =
                        newValue; // mengubah negara terpilih saat dropdown diganti
                  });
                  universityCubit.fetchData(
                      newValue); // mengambil data universitas berdasarkan negara terpilih
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
            BlocBuilder<UniversityCubit, List<UniversityModel>>(
              // widget BlocBuilder untuk mengambil data dari UniversityCubit
              builder: (context, universities) {
                // builder method untuk membangun UI berdasarkan data universities
                if (universities.isNotEmpty) {
                  // jika data universities tidak kosong
                  return Expanded(
                    // widget Expanded untuk menyesuaikan tinggi ListView dengan konten
                    child: ListView.builder(
                      // widget ListView untuk menampilkan list universitas
                      itemCount: universities
                          .length, // jumlah item list sesuai dengan data universities
                      itemBuilder: (context, index) {
                        // builder method untuk membangun item list
                        return Card(
                          // widget Card untuk menampilkan data universitas dalam bentuk card
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    universities[index].name,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Center(
                                  child: Text(
                                    universities[index].website,
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
                  );
                } else {
                  return CircularProgressIndicator(); // widget CircularProgressIndicator jika data belum dimuat
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

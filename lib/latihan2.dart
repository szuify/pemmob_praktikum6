import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

// event parent
abstract class UniversityEvent {}

// model berisi data/state
class UniversityModel {
  String name; // nama universitas
  String website; // website universitas

  // konstruktor untuk inisialisasi objek UniversityModel
  UniversityModel({required this.name, required this.website});

  // method untuk mengonversi data JSON ke objek UniversityModel
  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

// class untuk event mulai pengambilan data universitas
class FetchUniversityEvent extends UniversityEvent {
  String country; // untuk menyimpan nama negara

  FetchUniversityEvent(
      this.country); // konstruktor untuk inisialisasi event dengan nama negara
}

// perlu ada parameter event selain model, beda dgn Cubit yg hanya perlu model
class UniversityBloc extends Bloc<UniversityEvent, List<UniversityModel>> {
  UniversityBloc() : super([]) {
    // constructor untuk inisialisasi state Universitas kosong
    // penanganan event
    on<FetchUniversityEvent>((event, emit) {
      fetchData(event.country); // request mengambil data universitas
    });
  }

  void fetchData(String country) async {
    String url =
        "http://universities.hipolabs.com/search?country=$country"; // URL dasar API
    final response = await http.get(Uri.parse(url)); // HTTP GET request

    if (response.statusCode == 200) {
      // jika request berhasil (status code 200)
      List<dynamic> data = jsonDecode(response.body); // dekode data JSON
      List<UniversityModel> universities = [];

      data.forEach((university) {
        universities.add(UniversityModel.fromJson(
            university)); // menambahkan UniversityModel ke dalam list
      });

      emit(universities); // ambil data selesai
    } else {
      throw Exception('Gagal load'); // throw jika gagal memuat data
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
        create: (_) => UniversityBloc(), // membuat instance dari UniversityBloc
        child: HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  @override
  _HalamanUtamaState createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late UniversityBloc
      universityBloc; // instance UniversityBloc untuk mengakses data universitas
  String selectedCountry =
      'Indonesia'; // nilai dropdown default diatur ke 'Indonesia' untuk awal

  @override
  void initState() {
    super.initState();
    universityBloc = BlocProvider.of<UniversityBloc>(
        context); // mengambil instance dari UniversityBloc
    universityBloc.fetchData(
        selectedCountry); // memanggil fetchData untuk mengambil data universitas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'List Universitas - $selectedCountry'), // judul aplikasi - negara yang dipilih
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedCountry,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedCountry = newValue;
                  });
                  universityBloc.add(FetchUniversityEvent(
                      newValue!)); // mengirim event dengan nilai negara yang dipilih
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
            BlocBuilder<UniversityBloc, List<UniversityModel>>(
              builder: (context, universities) {
                if (universities.isNotEmpty) {
                  // jika data universitas tidak kosong
                  return Expanded(
                    child: ListView.builder(
                      itemCount: universities
                          .length, // jumlah item dalam list universitas
                      itemBuilder: (context, index) {
                        return Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    universities[index]
                                        .name, // menampilkan nama universitas
                                    style: TextStyle(
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Center(
                                  child: Text(
                                    universities[index]
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
                  );
                } else {
                  return CircularProgressIndicator(); // menampilkan indikator loading jika data belum dimuat
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:typed_data'; // Para trabajar con datos binarios
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart'; // Importa ImagePicker para web
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController descriptionController = TextEditingController();
  Uint8List? _imageBytes; // Para almacenar la imagen seleccionada
  String? _imageUrl; // Para almacenar la URL de la imagen subida
  LatLng? _location; // Para almacenar la ubicación seleccionada

  // Seleccionar imagen desde el navegador web
  Future<void> pickImage() async {
    Uint8List? pickedFile = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      if (pickedFile != null) {
        _imageBytes = pickedFile;
      }
    });
  }

  // Método para mostrar el mapa y seleccionar una ubicación
  Future<void> pickLocation() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar ubicación'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GoogleMap(
              onTap: (LatLng latLng) {
                setState(() {
                  _location = latLng; // Guardar la ubicación seleccionada
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Coordenadas iniciales (San Francisco)
                zoom: 10,
              ),
              markers: _location != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected-location'),
                        position: _location!,
                      )
                    }
                  : {},
            ),
          ),
        );
      },
    );
  }

  // Subir imagen a Firebase Storage y crear el reporte
  Future<void> uploadImageAndCreateReport() async {
    if (_imageBytes != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      try {
        // Subir imagen como bytes a Firebase Storage
        UploadTask uploadTask = _storage.ref('report_images/$fileName').putData(_imageBytes!);
        TaskSnapshot snapshot = await uploadTask;

        // Obtener la URL de descarga
        _imageUrl = await snapshot.ref.getDownloadURL();

        // Crear el reporte
        await _firestore.collection('reports').add({
          'description': descriptionController.text,
          'userId': _auth.currentUser!.uid,
          'imageUrl': _imageUrl,
          'location': _location != null ? GeoPoint(_location!.latitude, _location!.longitude) : null,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Limpiar el formulario
        descriptionController.clear();
        setState(() {
          _imageBytes = null; // Limpiar la imagen
          _location = null; // Limpiar ubicación después de enviar el reporte
        });

        // Mostrar SnackBar con el mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte creado exitosamente')),
        );

        print("Reporte creado exitosamente");
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Reporte'),
        backgroundColor: Colors.blueAccent, // Color del AppBar
      ),
      body: Container(
        width: double.infinity, // Asegura que el contenedor cubra todo el ancho
        height: double.infinity, // Asegura que el contenedor cubra toda la altura
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.white], // Colores del fondo
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centra los elementos
            children: [
              const SizedBox(height: 20),
              Text(
                'Descripción del Reporte',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ingrese la descripción',
                  fillColor: Colors.white,
                  filled: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Color del botón
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Botón más grande
                  textStyle: const TextStyle(fontSize: 18), // Aumenta el tamaño del texto
                ),
                child: Text(_imageBytes != null ? 'Imagen guardada' : 'Seleccionar Imagen'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Color del botón
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Botón más grande
                  textStyle: const TextStyle(fontSize: 18), // Aumenta el tamaño del texto
                ),
                child: const Text('Seleccionar Ubicación'),
              ),
              if (_location != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Ubicación seleccionada: ${_location!.latitude}, ${_location!.longitude}', style: TextStyle(fontSize: 16)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadImageAndCreateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Color del botón
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Botón más grande
                  textStyle: const TextStyle(fontSize: 18), // Aumenta el tamaño del texto
                ),
                child: const Text('Enviar Reporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

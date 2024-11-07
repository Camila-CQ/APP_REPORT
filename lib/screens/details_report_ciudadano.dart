import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailsReportCiudadano extends StatelessWidget {
  final String reportId; // ID del reporte a mostrar

  const DetailsReportCiudadano({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Reporte'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('reports').doc(reportId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Reporte no encontrado'));
          }

          var reportData = snapshot.data!.data() as Map<String, dynamic>;

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descripción del usuario:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      SizedBox(height: 10),
                      Text(
                        reportData['description'] ?? 'Sin descripción',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Estado del reporte:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      SizedBox(height: 10),
                      Text(
                        reportData['status'] ?? 'Sin estado',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Descripción de seguimiento:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      SizedBox(height: 10),
                      Text(
                        reportData['adminDescription'] ?? 'Sin descripción de seguimiento',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      if (reportData['finalImageUrl'] != null && reportData['finalImageUrl'].isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Imagen final:',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                            const SizedBox(height: 10),
                            CachedNetworkImage(
                              imageUrl: reportData['finalImageUrl'],
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  Text(
                                    'Error al cargar la imagen',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ],
                        )
                      else
                        Text(
                          'No hay imagen final disponible.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Fecha:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      SizedBox(height: 10),
                      Text(
                        reportData['timestamp'] != null
                            ? reportData['timestamp'].toDate().toString()
                            : 'Desconocida',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

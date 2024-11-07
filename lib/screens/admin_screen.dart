import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'report_details_screen.dart'; // Importar la pantalla de detalles
import 'package:app_report/services/firebase_services.dart'; // Asegúrate de que el path sea correcto

class AdminScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService(); // Instancia del servicio Firebase

  AdminScreen({super.key});

  Future<void> signOut(BuildContext context) async {
    await _firebaseService.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navegar a la pantalla de login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Reportes'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context), // Llama al método para cerrar sesión
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reports').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var reports = snapshot.data!.docs;

            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                var report = reports[index].data() as Map<String, dynamic>?; // Asegúrate de que esto sea Map

                // Verifica si report no es nulo y si el campo 'status' existe
                String status = report != null && report.containsKey('status')
                    ? report['status'] 
                    : 'Estado no disponible';

                // Incluye "en mora" si corresponde
                if (status == 'en mora') {
                  status = 'En Mora'; 
                }

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      report?['description'] ?? 'Sin descripción',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Estado: $status',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navegar a la pantalla de detalles del reporte
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDetailsScreen(reportId: reports[index].id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

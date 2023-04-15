import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FireBasexXano',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CollectionReference _details =
      FirebaseFirestore.instance.collection('details');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  
  void _createData() async {
    final response = await http.post(
      Uri.parse('https://x8ki-letl-twmt.n7.xano.io/api:xeBu2qHO/details'),
      body: jsonEncode({
        'name': _nameController.text,
        'email': _emailController.text,
        'address': _addressController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _emailController.text = documentSnapshot['email'];
      _addressController.text = documentSnapshot['address'];
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: TextButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Update'),
                onPressed: () async {
                  final String name = _nameController.text;
                  final String address = _addressController.text;
                  final String email = _emailController.text;
                  if (email != null) {
                    await _details.doc(documentSnapshot!.id).update(
                        {"name": name, "email": email, "address": address});
                    _nameController.text = '';
                    _emailController.text = '';
                    _addressController.text = '';
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'address'),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'email'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: TextButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Create'),
                onPressed: () async {
                  final String name = _nameController.text;
                  final String address = _addressController.text;
                  final String email = _emailController.text;
                  if (email != null) {
                    await _details.add(
                        {"name": name, "email": email, "address": address});
                    _createData();
                    _nameController.text = '';
                    _emailController.text = '';
                    _addressController.text = '';
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(String detailsId) async {
    await _details.doc(detailsId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully deleted the details')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 5.0,
        backgroundColor: Colors.teal,
        title: const Text(
          'FirebasexXano',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          _create();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _details.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  color: Colors.teal,
                  elevation: 5.0,
                  margin: const EdgeInsets.only(
                    top: 20.0,
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: ListTile(
                    title: Text(documentSnapshot['name']),
                    subtitle: Row(
                      children: [
                        Text(documentSnapshot['email']),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Text(documentSnapshot['address']),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100.0,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _update(documentSnapshot);
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () {
                              _delete(documentSnapshot.id);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

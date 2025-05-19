import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DistrictSchoolManagementPage extends StatefulWidget {
   DistrictSchoolManagementPage({super.key});

  @override
  State<DistrictSchoolManagementPage> createState() => _DistrictSchoolManagementPageState();
}

class _DistrictSchoolManagementPageState extends State<DistrictSchoolManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _districtFormKey = GlobalKey<FormState>();
  final _schoolFormKey = GlobalKey<FormState>();

  // District form fields
  String _districtName = "";
  String _region = 'Andijan'; // Default to Andijan

  // School form fields
  String? _selectedDistrictId;
  TextEditingController _schoolName = TextEditingController();
  String _schoolType = 'General';
  TextEditingController _address = TextEditingController();
  TextEditingController _contactPhone = TextEditingController();
  TextEditingController _principalName = TextEditingController();
  TextEditingController districtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title:  Text('Tuman/Shahar & Maktab qo\'shish'),
          bottom:  TabBar(
            tabs: [
              Tab(text: 'Tuman va Shaharlar'),
              Tab(text: 'Maktablar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Districts Tab
            _buildDistrictsTab(),
            // Schools Tab
            _buildSchoolsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDistrictsTab() {
    return Padding(
      padding: REdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add District Form
          Card(
            child: Padding(
              padding: REdgeInsets.all(16.0),
              child: Form(
                key: _districtFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  Text(
                  'Yangi tuman/shahar qo\'shish',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: districtController,
                    decoration:  InputDecoration(
                      labelText: 'Tuman nomi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tuman nomini kiriting';
                      }
                      return null;
                    },
                    onSaved: (value) => _districtName = value!,
                  ),
                   SizedBox(height: 16.h), DropdownButtonFormField<String>(
                    decoration:  InputDecoration(
                      labelText: 'Tuman',
                      border: OutlineInputBorder(),
                    ),
                    value: _region,
                    items:  [
                      DropdownMenuItem(value: 'Andijan', child: Text('Andijan')),
                      // Add other regions if needed
                    ],
                    onChanged: (value) {
                      setState(() {
                        _region = value!;
                      });
                    },
                  ),
                   SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _addDistrict,
                    child:  Text('Tumanni Saqlash'),
                  ),
                  ],
                ),
              ),
            ),
          ),
           SizedBox(height: 24.h),
          // Districts List
           Text(
            'Barcha Tumanlar',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('districts').orderBy('name').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['name']??""),
                        subtitle: Text(data['region']??""),
                        trailing: IconButton(
                          icon:  Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteDistrict(doc.id),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsTab() {
    return Padding(
      padding:  REdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add School Form
          Card(
            child: Padding(
              padding:  REdgeInsets.all(16.0),
              child: Form(
                key: _schoolFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     Text(
                      'Yangi Maktab Qo\'shish',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                     SizedBox(height: 16),
                    // District Dropdown
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('districts').orderBy('name').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return  CircularProgressIndicator();
                        }

                        final districts = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          decoration:  InputDecoration(
                            labelText: 'Tuman',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedDistrictId,
                          items: districts.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(data['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              log(value.toString());
                              _selectedDistrictId = value;
                            });
                          },
                          validator: (value) => value == null ? 'Iltimos  tumanni tanlang' : null,
                        );
                      },
                    ),
                     SizedBox(height: 16),
                    TextFormField(
                      decoration:  InputDecoration(
                        labelText: 'Maktab nomi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Matab nomini kiriting';
                        }
                        return null;
                      },
                      onSaved: (value) => _schoolName.text = value!,
                    ),
                     SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      decoration:  InputDecoration(
                        labelText: 'Maktab turi',
                        border: OutlineInputBorder(),
                      ),
                      value: _schoolType,
                      items:  [
                        DropdownMenuItem(value: 'General', child: Text('General Education')),
                        DropdownMenuItem(value: 'IDUM', child: Text('IDUM')),
                        DropdownMenuItem(value: 'DIMI', child: Text('DIMI')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _schoolType = value!;
                        });
                      },
                    ),
                     SizedBox(height: 16.h),
                    TextFormField(
                      decoration:  InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => _address.text = value ?? '',
                    ),
                     SizedBox(height: 16.h
                     ),
                    TextFormField(
                      decoration:  InputDecoration(
                        labelText: 'Bog\'lanish raqami',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      onSaved: (value) => _contactPhone.text = value ?? '',
                    ),
                     SizedBox(height: 16.h),
                    TextFormField(
                      decoration:  InputDecoration(
                        labelText: 'Direqtor ismi',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => _principalName.text = value ?? '',
                    ),
                     SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addSchool,
                      child:  Text('Maktabni Saqlash'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Schools List with Filter
          Row(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('schools').orderBy('name').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return DropdownButton(
                        items: [],
                        onChanged: null,
                        hint: Text('tumanlar yuklanmoqda...'),
                      );
                    }

                    final districts = snapshot.data!.docs;

                    return DropdownButton<String>(
                      value: _selectedDistrictId,
                      items: [
                         DropdownMenuItem(
                          value: null,
                          child: Text('Barcha Maktablar'),
                        ),
                        ...districts.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(data['name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrictId = value;
                        });
                      },
                      hint:  Text('Filter by district'),
                    );
                  },
                ),
              ),
            ],
          ),
           SizedBox(height: 8.h),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedDistrictId == null
                  ? _firestore.collection('schools').orderBy('name').snapshots()
                  : _firestore
                  .collection('schools')
                  .where('districtId', isEqualTo: _selectedDistrictId)
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['districtName']),
                            Text(data['type']),
                          ],
                        ),
                        trailing: IconButton(
                          icon:  Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSchool(doc.id),
                        ),
                        onTap: () => _editSchool(doc),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addDistrict() async {
    if (_districtFormKey.currentState!.validate()) {
      _districtFormKey.currentState!.save();

      try {
        await _firestore.collection('districts').add({
          'name': districtController.text,
          'region': _region,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Tuman muvafaqiyatli qo\'shildi!')),
        );

        _districtFormKey.currentState!.reset();
        setState(() {
          _districtName = '';
          _region = 'Andijan';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding district: $e')),
        );
      }
      districtController.clear();
    }
  }

  Future<void> _addSchool() async {
    if (_schoolFormKey.currentState!.validate()) {
      _schoolFormKey.currentState!.save();

      if (_selectedDistrictId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Please select a district')),
        );
        return;
      }

      try {
        // Get district name for denormalization
        final districtDoc = await _firestore.collection('districts').doc(_selectedDistrictId).get();
        final districtName = districtDoc['name'];

        await _firestore.collection('schools').add({
          'name': _schoolName.text,
          'districtId': _selectedDistrictId,
          'districtName': districtName,
          'type': _schoolType,
          'address': _address.text,
          'contactPhone': _contactPhone.text,
          'principalName': _principalName.text,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Maktab  muvafaqiyatli qo\'shildi!')),
        );

        _schoolFormKey.currentState!.reset();
        setState(() {
          _schoolName.clear();
          _schoolType = 'General';
          _address.clear();
          _contactPhone.clear();
          _principalName.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding school: $e')),
        );
      }
    }
  }

  Future<void> _deleteDistrict(String districtId) async {
    // Check if district has schools first
    final schoolsSnapshot = await _firestore
        .collection('schools')
        .where('districtId', isEqualTo: districtId)
        .get();

    if (schoolsSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Maktabni o\'chirib bo\'lmadi')),
      );
      return;
    }

    try {
      await _firestore.collection('districts').doc(districtId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Tuman o\'chirildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting district: $e')),
      );
    }
  }

  Future<void> _deleteSchool(String schoolId) async {
    // Check if school has students first
    final studentsSnapshot = await _firestore
        .collection('users')
        .where('schoolId', isEqualTo: schoolId)
        .limit(1)
        .get();

    if (studentsSnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Maktab o\'chirib bo\'lmadi')),
      );
      return;
    }

    try {
      await _firestore.collection('schools').doc(schoolId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Maktab o\'chirildi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting school: $e')),
      );
    }
  }

  Future<void> _editSchool(DocumentSnapshot schoolDoc) async {
    final data = schoolDoc.data() as Map<String, dynamic>;


  }
}
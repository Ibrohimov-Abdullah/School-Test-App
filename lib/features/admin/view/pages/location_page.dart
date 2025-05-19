import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LocationManagementScreen extends StatelessWidget {
  const LocationManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Joylashuvlar boshqaruvi', style: TextStyle(fontSize: 18.sp)),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Shaharlar', icon: Icon(Icons.location_city)),
              Tab(text: 'Tumanlar', icon: Icon(Icons.map)),
              Tab(text: 'Maktablar', icon: Icon(Icons.school)),
              Tab(text: "Mavjud Maktablar", icon: Icon(Icons.school))
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CitiesTab(),
            DistrictsTab(),
            SchoolsTab(),
            MavjudMK(),
          ],
        ),
      ),
    );
  }
}

class MavjudMK extends StatelessWidget {
  const MavjudMK({super.key});

  @override
  Widget build(BuildContext context) {
    return buildSchoolsList();
  }
}

class CitiesTab extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Yangi shahar qo\'shish',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Shahar nomi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Shahar nomini kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: 'Viloyat',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Viloyat nomini kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _addCity,
                      child: Text('Qo\'shish'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _buildCitiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cities').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}', style: TextStyle(fontSize: 14.sp)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final cities = snapshot.data!.docs;

        if (cities.isEmpty) {
          return Center(
            child: Text(
              'Shaharlar mavjud emas',
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }

        return ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            final cityData = city.data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(cityData['name'] ?? 'Noma\'lum', style: TextStyle(fontSize: 14.sp)),
                subtitle: Text(cityData['region'] ?? 'Noma\'lum', style: TextStyle(fontSize: 12.sp)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.w),
                      onPressed: () => _showEditCityDialog(city),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20.w, color: Colors.red),
                      onPressed: () => _deleteCity(city.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addCity() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('cities').add({
          'name': _nameController.text,
          'region': _regionController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _nameController.clear();
        _regionController.clear();
        Get.snackbar('Muvaffaqiyatli', 'Shahar qo\'shildi', snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Xatolik', 'Shahar qo\'shib bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _showEditCityDialog(DocumentSnapshot city) {
    final cityData = city.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: cityData['name'] ?? '');
    final regionController = TextEditingController(text: cityData['region'] ?? '');

    Get.dialog(
      AlertDialog(
        title: Text('Shaharni tahrirlash', style: TextStyle(fontSize: 16.sp)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Shahar nomi'),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: regionController,
                decoration: InputDecoration(labelText: 'Viloyat'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('cities').doc(city.id).update({
                  'name': nameController.text,
                  'region': regionController.text,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Get.back();
                Get.snackbar('Muvaffaqiyatli', 'Shahar yangilandi', snackPosition: SnackPosition.BOTTOM);
              } catch (e) {
                Get.snackbar('Xatolik', 'Shaharni yangilab bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _deleteCity(String cityId) async {
    Get.defaultDialog(
      title: 'Shaharni o\'chirish',
      middleText: 'Haqiqatan ham bu shaharni o\'chirmoqchimisiz?',
      textConfirm: 'Ha',
      textCancel: 'Yo\'q',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance.collection('cities').doc(cityId).delete();
          Get.back();
          Get.snackbar('Muvaffaqiyatli', 'Shahar o\'chirildi', snackPosition: SnackPosition.BOTTOM);
        } catch (e) {
          Get.snackbar('Xatolik', 'Shaharni o\'chirib bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
        }
      },
    );
  }
}

class DistrictsTab extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();
  String? _selectedCityId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Yangi tuman qo\'shish',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('cities').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final cities = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Shahar',
                            border: OutlineInputBorder(),
                          ),
                          items: cities.map((city) {
                            final cityData = city.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: city.id,
                              child: Text(cityData['name'] ?? 'Noma\'lum', style: TextStyle(fontSize: 14.sp)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _selectedCityId = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Shaharni tanlang';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tuman nomi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tuman nomini kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: 'Viloyat',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Viloyat nomini kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _addDistrict,
                      child: Text('Qo\'shish'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: _buildDistrictsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('districts').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}', style: TextStyle(fontSize: 14.sp)));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final districts = snapshot.data!.docs;

        if (districts.isEmpty) {
          return Center(
            child: Text(
              'Tumanlar mavjud emas',
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }

        return ListView.builder(
          itemCount: districts.length,
          itemBuilder: (context, index) {
            final district = districts[index];
            final districtData = district.data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.only(bottom: 8.h),
              child: ListTile(
                title: Text(districtData['name'] ?? 'Noma\'lum', style: TextStyle(fontSize: 14.sp)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(districtData['region'] ?? 'Noma\'lum', style: TextStyle(fontSize: 12.sp)),
                    FutureBuilder<DocumentSnapshot?>(
                      future: districtData['cityId']?.toString().isNotEmpty == true
                          ? FirebaseFirestore.instance.collection('cities').doc(districtData['cityId']).get()
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Shahar: Yuklanmoqda...', style: TextStyle(fontSize: 12.sp));
                        }

                        if (snapshot.hasError || snapshot.data == null || !snapshot.data!.exists) {
                          return Text('Shahar: Noma\'lum', style: TextStyle(fontSize: 12.sp));
                        }

                        final cityData = snapshot.data!.data() as Map<String, dynamic>;
                        return Text('Shahar: ${cityData['name'] ?? 'Noma\'lum'}', style: TextStyle(fontSize: 12.sp));
                      },
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20.w),
                      onPressed: () => _showEditDistrictDialog(district),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20.w, color: Colors.red),
                      onPressed: () => _deleteDistrict(district.id),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addDistrict() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('districts').add({
          'name': _nameController.text,
          'region': _regionController.text,
          'cityId': _selectedCityId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _nameController.clear();
        _regionController.clear();
        _selectedCityId = null;
        Get.snackbar('Muvaffaqiyatli', 'Tuman qo\'shildi', snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Xatolik', 'Tuman qo\'shib bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _showEditDistrictDialog(DocumentSnapshot district) {
    final districtData = district.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: districtData['name'] ?? '');
    final regionController = TextEditingController(text: districtData['region'] ?? '');
    String? selectedCityId = districtData['cityId'];

    Get.dialog(
      AlertDialog(
        title: Text('Tumanni tahrirlash', style: TextStyle(fontSize: 16.sp)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('cities').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final cities = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: selectedCityId,
                    decoration: InputDecoration(labelText: 'Shahar'),
                    items: cities.map((city) {
                      final cityData = city.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: city.id,
                        child: Text(cityData['name'] ?? 'Noma\'lum', style: TextStyle(fontSize: 14.sp)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedCityId = value;
                    },
                  );
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tuman nomi'),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: regionController,
                decoration: InputDecoration(labelText: 'Viloyat'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('districts').doc(district.id).update({
                  'name': nameController.text,
                  'region': regionController.text,
                  'cityId': selectedCityId,
                  'updatedAt': FieldValue.serverTimestamp(),
                });
                Get.back();
                Get.snackbar('Muvaffaqiyatli', 'Tuman yangilandi', snackPosition: SnackPosition.BOTTOM);
              } catch (e) {
                Get.snackbar('Xatolik', 'Tumanni yangilab bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _deleteDistrict(String districtId) async {
    Get.defaultDialog(
      title: 'Tumanni o\'chirish',
      middleText: 'Haqiqatan ham bu tumannni o\'chirmoqchimisiz?',
      textConfirm: 'Ha',
      textCancel: 'Yo\'q',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance.collection('districts').doc(districtId).delete();
          Get.back();
          Get.snackbar('Muvaffaqiyatli', 'Tuman o\'chirildi', snackPosition: SnackPosition.BOTTOM);
        } catch (e) {
          Get.snackbar('Xatolik', 'Tumanni o\'chirib bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
        }
      },
    );
  }
}

class SchoolsTab extends StatelessWidget {

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _principalController = TextEditingController();
  String? _selectedDistrictId;
  String _selectedType = 'General';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Yangi maktab qo\'shish',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('districts').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final districts = snapshot.data!.docs;
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Tuman',
                            border: OutlineInputBorder(),
                          ),
                          items: districts.map((district) {
                            final districtData = district.data() as Map<String, dynamic>;
                            return DropdownMenuItem<String>(
                              value: district.id,
                              child: Text(districtData['name'] ?? 'Noma\'lum', style: TextStyle(fontSize: 14.sp)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            _selectedDistrictId = value;
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Tumanni tanlang';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Maktab nomi',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Maktab nomini kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Manzil',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Manzilni kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefon raqam',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Telefon raqamini kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _principalController,
                      decoration: InputDecoration(
                        labelText: 'Direktor FIO',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Direktor ismini kiriting';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      onChanged: (value) {
                        _selectedType = value!;
                      },
                      decoration: InputDecoration(
                        labelText: 'Maktab turi',
                        border: OutlineInputBorder(),
                      ),
                      items: ['General', 'Specialized', 'Private']
                          .map(
                            (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _addSchool,
                      child: Text('Qo\'shish'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: buildSchoolsList(),
          ),
        ],
      ),
    );
  }

  void _addSchool() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('schools').add({
          'name': _nameController.text,
          'address': _addressController.text,
          'contactPhone': _phoneController.text,
          'principalName': _principalController.text,
          'type': _selectedType,
          'districtId': _selectedDistrictId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _nameController.clear();
        _addressController.clear();
        _phoneController.clear();
        _principalController.clear();
        _selectedDistrictId = null;
        Get.snackbar('Muvaffaqiyatli', 'Maktab qo\'shildi', snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Xatolik', 'Maktab qo\'shib bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}

Widget buildSchoolsList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('schools').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Xatolik yuz berdi: ${snapshot.error}', style: TextStyle(fontSize: 14.sp)));
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      final schools = snapshot.data!.docs;

      if (schools.isEmpty) {
        return Center(
          child: Text(
            'Maktablar mavjud emas',
            style: TextStyle(fontSize: 16.sp),
          ),
        );
      }

      return ListView.builder(
        itemCount: schools.length,
        itemBuilder: (context, index) {
          final school = schools[index];
          final schoolData = school.data() as Map<String, dynamic>;
          return Card(
            margin: EdgeInsets.only(bottom: 8.h),
            child: ListTile(
              title: Text(schoolData['name'] ?? 'Noma\'lum', style: TextStyle(fontSize: 14.sp)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(schoolData['address'] ?? 'Noma\'lum', style: TextStyle(fontSize: 12.sp)),
                  Text(schoolData['type'] ?? 'Noma\'lum', style: TextStyle(fontSize: 12.sp)),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('districts').doc(schoolData['districtId'] ?? '').get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final districtData = snapshot.data!.data() as Map<String, dynamic>;
                        return Text('Tuman: ${districtData['name'] ?? 'Noma\'lum'}', style: TextStyle(fontSize: 12.sp));
                      }
                      return Text('Tuman: Noma\'lum', style: TextStyle(fontSize: 12.sp));
                    },
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20.w),
                    onPressed: () => _showEditSchoolDialog(school),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20.w, color: Colors.red),
                    onPressed: () => _deleteSchool(school.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showEditSchoolDialog(DocumentSnapshot school) {
  final schoolData = school.data() as Map<String, dynamic>;
  final nameController = TextEditingController(text: schoolData['name'] ?? '');
  final addressController = TextEditingController(text: schoolData['address'] ?? '');
  final phoneController = TextEditingController(text: schoolData['contactPhone'] ?? '');
  final principalController = TextEditingController(text: schoolData['principalName'] ?? '');
  String? selectedDistrictId = schoolData['districtId'];
  String selectedType = schoolData['type'] ?? 'General';

  Get.dialog(
    AlertDialog(
      title: Text('Maktabni tahrirlash', style: TextStyle(fontSize: 16.sp)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('districts').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final districts = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  value: selectedDistrictId,
                  decoration: InputDecoration(labelText: 'Tuman'),
                  items: districts.map((district) {
                    final districtData = district.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: district.id,
                      child: Text(districtData['name'] ?? 'Noma\'lum', style: TextStyle(fontSize: 14.sp)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedDistrictId = value;
                  },
                );
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Maktab nomi'),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Manzil'),
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Telefon raqam'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: principalController,
              decoration: InputDecoration(labelText: 'Direktor FIO'),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(labelText: 'Maktab turi'),
              items: ['General', 'Specialized', 'Private']
                  .map((type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: TextStyle(fontSize: 14.sp)),
              ))
                  .toList(),
              onChanged: (value) {
                selectedType = value!;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Bekor qilish'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await FirebaseFirestore.instance.collection('schools').doc(school.id).update({
                'name': nameController.text,
                'address': addressController.text,
                'contactPhone': phoneController.text,
                'principalName': principalController.text,
                'type': selectedType,
                'districtId': selectedDistrictId,
                'updatedAt': FieldValue.serverTimestamp(),
              });
              Get.back();
              Get.snackbar('Muvaffaqiyatli', 'Maktab yangilandi', snackPosition: SnackPosition.BOTTOM);
            } catch (e) {
              Get.snackbar('Xatolik', 'Maktabni yangilab bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
            }
          },
          child: Text('Saqlash'),
        ),
      ],
    ),
  );
}

void _deleteSchool(String schoolId) async {
  Get.defaultDialog(
    title: 'Maktabni o\'chirish',
    middleText: 'Haqiqatan ham bu maktabni o\'chirmoqchimisiz?',
    textConfirm: 'Ha',
    textCancel: 'Yo\'q',
    confirmTextColor: Colors.white,
    onConfirm: () async {
      try {
        await FirebaseFirestore.instance.collection('schools').doc(schoolId).delete();
        Get.back();
        Get.snackbar('Muvaffaqiyatli', 'Maktab o\'chirildi', snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Xatolik', 'Maktabni o\'chirib bo\'lmadi: $e', snackPosition: SnackPosition.BOTTOM);
      }
    },
  );
}

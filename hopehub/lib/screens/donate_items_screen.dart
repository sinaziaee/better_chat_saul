import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DonateItemScreen extends StatefulWidget {
  @override
  _DonateItemScreenState createState() => _DonateItemScreenState();
}

class _DonateItemScreenState extends State<DonateItemScreen> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedAgeGroup;

  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Home & Garden': [
      {'name': 'Tools', 'icon': Icons.build},
      {'name': 'Furniture', 'icon': Icons.chair},
      {'name': 'Garden', 'icon': Icons.grass},
      {'name': 'Appliances', 'icon': Icons.kitchen},
      {'name': 'Household', 'icon': Icons.home},
    ],
    'Entertainment': [
      {'name': 'Books, Movies & Music', 'icon': Icons.book},
      {'name': 'Video Games', 'icon': Icons.videogame_asset},
    ],
    'Clothing & Accessories': [
      {'name': 'Jewelry & Accessories', 'icon': Icons.watch},
      {'name': 'Bags & Luggage', 'icon': Icons.backpack},
      {'name': 'Men\'s Clothing & Shoes', 'icon': Icons.male},
      {'name': 'Women\'s Clothing & Shoes', 'icon': Icons.female},
    ],
    'Family': [
      {'name': 'Toys & Games', 'icon': Icons.toys},
      {'name': 'Baby & Kids', 'icon': Icons.child_friendly},
      {'name': 'Pet Supplies', 'icon': Icons.pets},
      {'name': 'Health & Beauty', 'icon': Icons.health_and_safety},
    ],
    'Electronics': [
      {'name': 'Mobile Phones', 'icon': Icons.phone_iphone},
      {'name': 'Electronics & Computers', 'icon': Icons.computer},
    ],
    'Hobbies': [
      {'name': 'Sports & Outdoors', 'icon': Icons.sports},
      {'name': 'Musical Instruments', 'icon': Icons.music_note},
      {'name': 'Arts & Crafts', 'icon': Icons.palette},
    ],
  };

  final List<String> _conditions = [
    'New',
    'Like New',
    'Used',
    'Heavily Used',
  ];

  final List<String> _ageGroupOptions = [
    'Infant',
    'Child',
    'Boy',
    'Girl',
    'Woman',
    'Man',
    'General',
  ];

  Future<void> _pickImageFromGallery() async {
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _images.addAll(pickedImages);
      });
    }
  }

  Future<void> _takePictureWithCamera() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _images.add(photo);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _generateDescription() {
    setState(() {
      _descriptionController.text = 'Generated description based on images.';
    });
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (_, scrollController) {
            return ListView(
              controller: scrollController,
              children: _categories.entries.map((entry) {
                return ExpansionTile(
                  leading: Icon(Icons.category),
                  title: Text(entry.key),
                  children: entry.value
                      .map(
                        (subcategory) => ListTile(
                      leading: Icon(subcategory['icon']),
                      title: Text(subcategory['name']),
                      onTap: () {
                        setState(() {
                          _selectedCategory = subcategory['name'];
                        });
                        Navigator.pop(context);
                      },
                    ),
                  )
                      .toList(),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Listing'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Add Photos or Video:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _images.isEmpty
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _takePictureWithCamera,
                  icon: Icon(Icons.camera_alt, color: Colors.blue),
                  label: Text('Take a Picture', style: TextStyle(color: Colors.blue)),
                ),
                ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: Icon(Icons.photo_library, color: Colors.blue),
                  label: Text('Select from Gallery', style: TextStyle(color: Colors.blue)),
                ),
              ],
            )
                : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _images
                        .asMap()
                        .entries
                        .map(
                          (entry) => Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(
                              File(entry.value.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  _removeImage(entry.key),
                            ),
                          ),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _takePictureWithCamera,
                      icon: Icon(Icons.camera_alt),
                      label: Text('Take a Picture'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: Icon(Icons.add_photo_alternate),
                      label: Text('Add More Images'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _showCategoryPicker,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: _selectedCategory ?? 'Select a Category',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  style: TextStyle(
                    color: _selectedCategory != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: _conditions
                  .map((condition) => DropdownMenuItem(
                value: condition,
                child: Text(condition),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCondition = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Age Group',
                border: OutlineInputBorder(),
              ),
              items: _ageGroupOptions
                  .map((ageGroup) => DropdownMenuItem(
                value: ageGroup,
                child: Text(ageGroup),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAgeGroup = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.auto_fix_high, color: Colors.blue),
                  onPressed: _generateDescription,
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement submit logic
              },
              child: Text('Submit', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}

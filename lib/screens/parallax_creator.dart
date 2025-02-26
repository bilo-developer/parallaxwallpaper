import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:io';
import 'package:parallax/widgets/editable_element.dart'; // Yeni widget’ı import et
import 'package:parallax/screens/wallpaper_creator.dart'; // ColorPicker için import

class ParallaxCreator extends StatefulWidget {
  const ParallaxCreator({super.key});

  @override
  _ParallaxCreatorState createState() => _ParallaxCreatorState();
}

class _ParallaxCreatorState extends State<ParallaxCreator> {
  List<List<Widget>> layers = [
    [], // Foreground
    [], // Middle
    [], // Background
  ];
  int selectedLayer = 0;
  double parallaxDepth = 0.5;
  double xTilt = 0.0;
  double yTilt = 0.0;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        xTilt = event.x * 0.1; // Adjust sensitivity
        yTilt = event.y * 0.1;
      });
    });
  }

  void addImage(int layer) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      setState(() {
        layers[layer].add(
          EditableElement(
            child: pickedFile.path.endsWith('.gif')
                ? Image.file(File(pickedFile.path), fit: BoxFit.contain)
                : Image.file(File(pickedFile.path)),
            initialPosition: const Offset(0, 0),
          ),
        );
      });
    }
  }

  void addText(int layer) {
    setState(() {
      layers[layer].add(
        const EditableElement(
          child: SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter text',
              ),
              style: TextStyle(color: Colors.black),
              maxLines: 1,
              expands: false,
            ),
          ),
          initialPosition: Offset(0, 0),
        ),
      );
    });
  }

  void _showGradientDialog(int layer) {
    Color startColor = Colors.blue;
    Color endColor = Colors.purple;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Gradient Colors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColorPicker(
                color: startColor,
                onColorChanged: (color) => startColor = color,
                label: 'Start Color',
              ),
              const SizedBox(height: 16),
              ColorPicker(
                color: endColor,
                onColorChanged: (color) => endColor = color,
                label: 'End Color',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addGradient(layer, startColor, endColor);
              },
              child: const Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void addGradient(int layer, Color startColor, Color endColor) {
    setState(() {
      layers[layer].add(
        EditableElement(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          initialPosition: const Offset(0, 0),
        ),
      );
    });
  }

  void saveWallpaper(BuildContext context) async {
    // Simplified save for now (you can expand this to capture the entire Stack)
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parallax Wallpaper Saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Parallax Wallpaper',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Layer
          Transform.translate(
            offset: Offset(
                xTilt * parallaxDepth * 100, yTilt * parallaxDepth * 100),
            child: Container(
              color: Colors.grey[200],
              child: Stack(children: layers[2]),
            ),
          ),
          // Middle Layer
          Transform.translate(
            offset:
                Offset(xTilt * parallaxDepth * 50, yTilt * parallaxDepth * 50),
            child: Container(
              color: Colors.transparent,
              child: Stack(children: layers[1]),
            ),
          ),
          // Foreground Layer
          Transform.translate(
            offset:
                Offset(xTilt * parallaxDepth * 20, yTilt * parallaxDepth * 20),
            child: Container(
              color: Colors.transparent,
              child: Stack(children: layers[0]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple[50],
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: parallaxDepth,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  parallaxDepth = value;
                });
              },
              label: 'Parallax Depth',
              activeColor: Colors.purple,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.purple),
                  onPressed: () => addImage(selectedLayer),
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields, color: Colors.purple),
                  onPressed: () => addText(selectedLayer),
                ),
                IconButton(
                  icon: const Icon(Icons.gradient, color: Colors.purple),
                  onPressed: () => _showGradientDialog(selectedLayer),
                ),
                DropdownButton<int>(
                  value: selectedLayer,
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Foreground')),
                    DropdownMenuItem(value: 1, child: Text('Middle')),
                    DropdownMenuItem(value: 2, child: Text('Background')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedLayer = value!;
                    });
                  },
                  dropdownColor: Colors.purple[50],
                  style: const TextStyle(color: Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => saveWallpaper(context),
        child: const Icon(Icons.save, color: Colors.white),
        backgroundColor: Colors.purple,
        elevation: 4,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart'; // Import for RenderRepaintBoundary
import 'package:parallax/widgets/editable_element.dart';

class WallpaperCreator extends StatefulWidget {
  const WallpaperCreator({super.key});

  @override
  _WallpaperCreatorState createState() => _WallpaperCreatorState();
}

class _WallpaperCreatorState extends State<WallpaperCreator> {
  List<Widget> elements = [];
  final GlobalKey canvasKey = GlobalKey();

  void addImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      setState(() {
        elements.add(
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

  void addText() {
    setState(() {
      elements.add(
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

  void _showGradientDialog() {
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
                onColorChanged: (color) => setState(() => startColor = color),
                label: 'Start Color',
              ),
              const SizedBox(height: 16),
              ColorPicker(
                color: endColor,
                onColorChanged: (color) => setState(() => endColor = color),
                label: 'End Color',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                addGradient(startColor, endColor);
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

  void addGradient(Color startColor, Color endColor) {
    setState(() {
      elements.add(
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

  Future<void> saveWallpaper(BuildContext context) async {
    final boundary =
        canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/wallpaper_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(buffer);

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallpaper Saved to ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: canvasKey,
      appBar: AppBar(
        title: const Text('Create Wallpaper',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Stack(
        children: elements,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple[50],
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Colors.purple),
              onPressed: addImage,
            ),
            IconButton(
              icon: const Icon(Icons.text_fields, color: Colors.purple),
              onPressed: addText,
            ),
            IconButton(
              icon: const Icon(Icons.gradient, color: Colors.purple),
              onPressed: _showGradientDialog,
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

// ColorPicker widget’ı (const kullanımlarını kaldırdık, çünkü dinamik)
class ColorPicker extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;
  final String label;

  const ColorPicker(
      {super.key,
      required this.color,
      required this.onColorChanged,
      required this.label});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var color in [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.pink,
                Colors.black,
                Colors.white,
              ])
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                    widget.onColorChanged(color);
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    child: selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

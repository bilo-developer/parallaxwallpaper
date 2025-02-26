// lib/widgets/editable_element.dart
import 'package:flutter/material.dart';

class EditableElement extends StatefulWidget {
  final Widget child;
  final Offset initialPosition;
  final double scale; // Ölçek (boyutlandırma) için
  final double rotation; // Döndürme açısı (radyan cinsinden)

  const EditableElement({
    super.key,
    required this.child,
    this.initialPosition = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  @override
  _EditableElementState createState() => _EditableElementState();
}

class _EditableElementState extends State<EditableElement> {
  late Offset position;
  late double _scale;
  late double _rotation;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
    _scale = widget.scale;
    _rotation = widget.rotation;
  }

  void _updateScale(double newScale) {
    setState(() {
      _scale = newScale.clamp(0.1, 5.0); // Ölçek sınırları
    });
  }

  void _updateRotation(double newRotation) {
    setState(() {
      _rotation = newRotation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              position = Offset(
                position.dx + details.delta.dx,
                position.dy + details.delta.dy,
              );
            });
          },
          child: InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.1,
            maxScale: 5.0,
            onInteractionUpdate: (details) {
              _updateScale(details.scale); // Ölçek güncellemesi
            },
            child: Transform.rotate(
              angle: _rotation,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.purple, width: 1), // Seçimi göstermek için
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.child,
                    IconButton(
                      icon: const Icon(Icons.rotate_right,
                          size: 16, color: Colors.purple),
                      onPressed: () {
                        _updateRotation(_rotation +
                            0.1); // 90 derece döndür (radyan cinsinden)
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        feedback: widget.child, // Sürükleme sırasında gösterilecek
        childWhenDragging: Container(), // Sürüklenirken gizle
        onDraggableCanceled: (_, offset) {
          setState(() {
            position = offset;
          });
        },
      ),
    );
  }
}

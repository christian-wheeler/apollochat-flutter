library particle_widget;

import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'dart:math';

class ParticleWidget extends StatefulWidget {

  final Size size;

  ParticleWidget(this.size);

  @override
  ParticleWidgetState createState() => new ParticleWidgetState(size);
}

class ParticleWidgetState extends State<ParticleWidget> {

  NodeWithSize rootNode;
  Size size;

  ParticleWidgetState(this.size);

  List<ParticleNode> nodes = [];

  @override
  void initState() {
    super.initState();
    rootNode = new NodeWithSize(size);

    // Create a random amount of nodes
    var divider = 70 * 70; // 110 * 110
    var bounds = size.width * size.height / divider;
    for (var i = 0; i < bounds.toInt(); i++) {
      nodes.add(createNode());
    }

    // Add all the nodes to the root node
    for (var node in nodes) {
      node.addImpulse();
      rootNode.addChild(node);
    }

    // Create edges between nodes
    for (var n1 in nodes) {
      for (var n2 in nodes) {
        rootNode.addChild(EdgeNode(n1, n2, size.height / 10));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var widget = SpriteWidget(rootNode, SpriteBoxTransformMode.fixedWidth);
    print(widget.rootNode.size);
    return widget;
  }

  createNode() {
    var random = Random();

    // Generate a random radius.
    var min = 45;
    var max = 120;
    var amount = (min + random.nextInt(max - min)) / 10000.0;
    var radius = amount * size.width;

    // Generate a random x.
    var x = random.nextDouble() * size.width;

    // Generate a random y.
    var y = random.nextDouble() * size.height;

    // Create and return node.
    return ParticleNode(radius)..position = Offset(x, y);
  }
}

class ParticleNode extends Node {

  ParticleNode(this.radius);

  Offset vector;
  double speed;
  double radius;

  @override
  void paint(Canvas canvas) {
    canvas.drawCircle(
        Offset.zero,
        radius,
        new Paint()..color = const Color(0xff53ACF1)
    );
  }

  @override
  void update(double dt) {
    // Move the node at a constant speed

    // if (vector != null) position += Offset(vector.dx, vector.dy * 100);

    var xMax = parent.spriteBox.size.width - radius;
    var yMax = parent.spriteBox.size.height - radius;

    if (position.dx >= xMax || position.dx <= radius) {
      vector = Offset(vector.dx * -1, vector.dy);
    }

    if (position.dy >= yMax || position.dy <= radius) {
      vector = Offset(vector.dx, vector.dy * -1);
    }

    position += Offset(dt * vector.dx, dt * vector.dy);
  }

  void addImpulse() {
    var random = Random();

    // Generate a random direction.
    var min = 0;
    var max = 360;
    var degrees = (min + random.nextInt(max - min));
    var radians = degrees * pi;

    // Generate a random speed.
    min = 65;
    max = 75;
    speed = (min + random.nextInt(max - min)) / 1000.0;

    var x = cos(radians) * speed * pow(10, 2);
    var y = sin(radians) * speed * pow(10, 15);

    print('result degrees $degrees x $x y $y speed $speed');

    vector = Offset(x, y);
  }
}

class EdgeNode extends Node {

  ParticleNode n1;
  ParticleNode n2;
  double max;

  EdgeNode(this.n1, this.n2, this.max);

  @override
  void paint(Canvas canvas) {
    var rect = Rect.fromPoints(n1.position, n2.position);
    var distance = rect.height > rect.width ? rect.height : rect.width;

    if (distance <= max) {
      var alpha = 1 - (distance / max);
      if (alpha < 0) alpha = 0.0;
      if (alpha > 1) alpha = 1.0;
      var color = Color(0xff53ACF1).withOpacity(alpha);
      canvas.drawLine(n1.position, n2.position, new Paint()..color = color ..strokeWidth = 0.6);
    }
  }
}
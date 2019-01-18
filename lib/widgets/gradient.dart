import 'package:flutter/material.dart';

// This is a perfect example of when it is okay to extract a Widget subtree
// into its own file. Since this widget doesn't depend on any upstream state,
// it can be extracted without affecting its working.
class GradientContainer extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: gradientDecoration(),
    );
  }
}

// Extract the BoxDecoration, since sometimes we only use that.
BoxDecoration gradientDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [
        // Notice that colours in Flutter correspond to HEX codes. The 0x
        // part preceding the HEX value is required since Flutter uses ints
        // to construct colours. The ff part denotes alpha levels, so this
        // can range between 00 and ff (100).
        Color(0xff53ACF1),
        Color(0xff6EEEFE)
      ]
    )
  );
}
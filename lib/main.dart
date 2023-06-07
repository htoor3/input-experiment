import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:input_experiment/native_input.dart';
// ignore: implementation_imports
import 'package:flutter/src/widgets/web_editable_text.dart';

void main() {
  runApp(const MyApp());
  // RendererBinding.instance.ensureSemantics();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  final focusNode = FocusNode();
  final cursorColor = Color(0xFFFF9000);
  final backgroundCursorColor = Color.fromARGB(255, 126, 18, 18);

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    myController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    myController.dispose();
    super.dispose();
  }

  void _printLatestValue() {
    print('text field: ${myController.text}');
  }

  TextStyle _getInputStyleForState(TextStyle style) {
    final TextStyle stateStyle = MaterialStateProperty.resolveAs(_m3StateInputStyle(context)!, _materialState);
    final TextStyle providedStyle = MaterialStateProperty.resolveAs(style, _materialState);
    return providedStyle.merge(stateStyle);
  }

  TextStyle? _m3StateInputStyle(BuildContext context) => MaterialStateTextStyle.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color?.withOpacity(0.38));
    }
    return TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color);
  });

    Set<MaterialState> get _materialState {
    return <MaterialState>{
      if (focusNode.hasFocus) MaterialState.focused,
    };
  }

  TextStyle _m3InputStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;

  @override
  Widget build(BuildContext context) {
    final style = _getInputStyleForState(_m3InputStyle(context));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            NativeInput(
              controller: myController,
              focusNode: FocusNode(),
              style: style,
              cursorColor: cursorColor,
              backgroundCursorColor: backgroundCursorColor,
            ),
            NativeInput(
              controller: myController,
              focusNode: FocusNode(),
              style: style,
              cursorColor: cursorColor,
              backgroundCursorColor: backgroundCursorColor,
              password: true,
            ),
            // TextField(
            //   controller: myController,
            // ),
            // NativeInput(
            //   password: true,
            //   controller: myController,
            //   focusNode: FocusNode(),
            //   style: style,
            //   cursorColor: cursorColor,
            //   backgroundCursorColor: backgroundCursorColor,
            // ),
            // EditableText(
            //     controller: myController,
            //     focusNode: FocusNode(),
            //     style: style,
            //     cursorColor: cursorColor,
            //     backgroundCursorColor: backgroundCursorColor),
            // WebEditableText(
            //     controller: myController,
            //     focusNode: FocusNode(),
            //     style: style,
            //     cursorColor: cursorColor,
            //     backgroundCursorColor: backgroundCursorColor),
          ],
        ),
      ),
    );
  }
}

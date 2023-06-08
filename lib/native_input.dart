// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui; // change to ui_web when you update
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/widgets.dart';

/// The web implementation of the `NativeInput` widget.
class NativeInput extends StatefulWidget {
  NativeInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.style,
    required this.cursorColor,
    required this.backgroundCursorColor,
    this.readOnly = false,
    this.obscuringCharacter = '•', // how to support?
    this.obscureText = false,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.onChanged,
    this.maxLines = 1,
  }) {
    viewType = '__webNativeInputViewType__${const Uuid().v4()}';
  }

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextStyle style;
  final Color cursorColor;
  final Color backgroundCursorColor;
  late final String viewType;
  final bool readOnly;
  final String obscuringCharacter;
  final bool obscureText;
  final TextAlign textAlign;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  State<NativeInput> createState() => _NativeInputState();
}

class _NativeInputState extends State<NativeInput> {
  late html.HtmlElement inputEl;
  html.InputElement? _inputElement;
  html.TextAreaElement? _textAreaElement;

  @override
  void initState() {
    super.initState();

    // create input element + init styling

    // conditionally create <textarea> or <input>
    if (widget.maxLines > 1) {
      _textAreaElement = html.TextAreaElement();
      _textAreaElement!.rows = widget.maxLines;
      inputEl = _textAreaElement!;
    } else {
      _inputElement = html.InputElement();
      _inputElement!.readOnly = widget.readOnly;

      if (widget.obscureText) {
        _inputElement!.type = 'password';
      }

      inputEl = _inputElement!;
    }

    // style based on TextStyle
    inputEl.style.cssText = textStyleToCss(widget.style);

    // reset input styles
    inputEl.style
      ..width = '100%'
      ..height = '100%'
      ..setProperty('caret-color', colorToCss(widget.cursorColor))
      ..outline = 'none'
      ..border = 'none'
      ..padding = '0'
      ..textAlign = widget.textAlign.name;

    
    // debug
    if(widget.obscureText){
      _inputElement!.style.border = '1px solid red'; // debug
    }

    // listen for events
    inputEl.onInput.listen((e) {
      final String currentText = getElementValue();
      widget.controller.text = currentText;

      if (widget.onChanged != null) {
        widget.onChanged?.call(currentText);
      }
    });

    inputEl.onFocus.listen((e) {
      widget.focusNode.requestFocus();
    });

    inputEl.onBlur.listen((e) {
      widget.focusNode.unfocus();
    });

    // register platform view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(widget.viewType, (int viewId) => inputEl);

    // add listeners for controller and focus
    widget.controller.addListener(_controllerListener);
    widget.focusNode.addListener(_focusListener);

    if (widget.autofocus) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        inputEl.focus();
      });
    }
  }

  void _controllerListener() {
    final String text = widget.controller.text;
    setElementValue(text);
  }

  void _focusListener() {
    if (widget.focusNode.hasFocus) {
      inputEl.focus();
    } else {
      inputEl.blur();
    }
  }

  @override
  void dispose() {
    print('disposed');
    widget.controller.removeListener(_controllerListener);
    widget.focusNode.removeListener(_focusListener);

    super.dispose();
  }

  String getElementValue() {
    return (widget.maxLines > 1
        ? _textAreaElement!.value
        : _inputElement!.value) as String;
  }

  void setElementValue(String value) {
    if (widget.maxLines > 1) {
      _textAreaElement!.value = value;
    } else {
      _inputElement!.value = value;
    }
  }

  String colorToCss(Color color) {
    return 'rgba(${color.red}, ${color.green}, ${color.blue}, ${color.opacity})';
  }

  String textStyleToCss(TextStyle style) {
    List<String> cssProperties = [];

    if (style.color != null) {
      cssProperties.add('color: ${colorToCss(style.color!)}');
    }

    if (style.fontSize != null) {
      cssProperties.add('font-size: ${style.fontSize}px');
    }

    if (style.fontWeight != null) {
      cssProperties.add('font-weight: ${style.fontWeight!.value}');
    }

    if (style.fontStyle != null) {
      cssProperties.add(
          'font-style: ${style.fontStyle == FontStyle.italic ? 'italic' : 'normal'}');
    }

    if (style.fontFamily != null) {
      cssProperties.add('font-family: ${style.fontFamily}');
    }

    if (style.letterSpacing != null) {
      cssProperties.add('letter-spacing: ${style.letterSpacing}px');
    }

    if (style.wordSpacing != null) {
      cssProperties.add('word-spacing: ${style.wordSpacing}');
    }

    if (style.decoration != null) {
      List<String> textDecorations = [];
      TextDecoration decoration = style.decoration!;

      if (decoration == TextDecoration.none) {
        textDecorations.add('none');
      } else {
        if (decoration.contains(TextDecoration.underline)) {
          textDecorations.add('underline');
        }

        if (decoration.contains(TextDecoration.underline)) {
          textDecorations.add('underline');
        }

        if (decoration.contains(TextDecoration.underline)) {
          textDecorations.add('underline');
        }
      }

      cssProperties.add('text-decoration: ${textDecorations.join(' ')}');
    }

    cssProperties.add('height: 50%');
    cssProperties.add('width: 50%');

    return cssProperties.join('; ');
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, e) {
        // needed to fix the bug where we need to hit shift+tab twice to switch focus
        if (e is RawKeyDownEvent && e.logicalKey == LogicalKeyboardKey.tab) {
          if (e.isShiftPressed) {
            Focus.of(context).previousFocus();
          } else {
            Focus.of(context).nextFocus();
          }

          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: SizedBox(
          height: 24,
          child: HtmlElementView(
            viewType: widget.viewType,
            // can pass in creationParams (map of things)
          )),
    );
  }
}

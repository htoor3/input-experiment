// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui; // change to ui_web when you update
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/widgets.dart';

/*
  line-height. 
*/

/// The web implementation of the `NativeInput` widget.
class NativeInput extends StatefulWidget {
  NativeInput(
      {super.key,
      required this.controller,
      required this.focusNode,
      required this.style,
      required this.cursorColor,
      required this.backgroundCursorColor, // not supported on web
      this.readOnly = false,
      this.obscuringCharacter = '•', // how to support?
      this.obscureText = false,
      this.textAlign = TextAlign.start,
      this.autofocus = false,
      this.onChanged,
      this.maxLines =
          1, // issues with height calc + fonts, todo keyboard type, inputaction
      this.textCapitalization = TextCapitalization.none,
      this.keyboardAppearance = Brightness.light, // not supported on web
      this.selectionColor,
      this.cursorWidth = 2.0, // not supported on web
      this.cursorHeight, // not supported on web
      this.cursorRadius, // not supported on web
      this.enableSuggestions = true, // not supported on web
      this.autocorrect = true, // Safari only
      this.undoController, // web handles its own undo
      this.smartDashesType, // not supported on web (ios only?)
      this.smartQuotesType, // not supported on web (ios only?)
      this.magnifierConfiguration =
          TextMagnifierConfiguration.disabled, // not supported on web
      this.spellCheckConfiguration, // not supported on web
      this.enableIMEPersonalizedLearning = true, // not supported on web
      this.scribbleEnabled = true, // possibly not supported on web?
      @Deprecated(
        'Use `contextMenuBuilder` instead. '
        'This feature was deprecated after v3.3.0-0.5.pre.',
      )
      this.toolbarOptions,
      this.autocorrectionTextRectColor,
      this.enableInteractiveSelection = true,
      this.selectionHeightStyle =
          ui.BoxHeightStyle.tight, // not supported on web
      this.selectionWidthStyle = ui.BoxWidthStyle.tight, // not supported on web
      this.paintCursorAboveText = false, // not supported on web
      this.cursorOpacityAnimates = false, // not supported on web
      this.cursorOffset, // not supported on web,
      this.rendererIgnoresPointer = false,
      this.textDirection,
      this.showCursor = true}) {
    assert(obscuringCharacter.length == 1);
    // // assert(minLines == null || minLines > 0);
    // assert(
    //   (maxLines == null) || (minLines == null) || (maxLines >= minLines),
    //   "minLines can't be greater than maxLines",
    // ),
    // assert(
    //   !expands || (maxLines == null && minLines == null),
    //   'minLines and maxLines must be null when expands is true.',
    // ),
    // assert(!obscureText || maxLines == 1, 'Obscured fields cannot be multiline.'),
    // enableInteractiveSelection = enableInteractiveSelection ?? (!readOnly || !obscureText);
    // toolbarOptions = selectionControls is TextSelectionHandleControls && toolbarOptions == null ? ToolbarOptions.empty : toolbarOptions ??
    //     (obscureText
    //         ? (readOnly
    //             // No point in even offering "Select All" in a read-only obscured
    //             // field.
    //             ? ToolbarOptions.empty
    //             // Writable, but obscured.
    //             : const ToolbarOptions(
    //                 selectAll: true,
    //                 paste: true,
    //               ))
    //         : (readOnly
    //             // Read-only, not obscured.
    //             ? const ToolbarOptions(
    //                 selectAll: true,
    //                 copy: true,
    //               )
    //             // Writable, not obscured.
    //             : const ToolbarOptions(
    //                 copy: true,
    //                 cut: true,
    //                 selectAll: true,
    //                 paste: true,
    //               )));
    //    assert(
    //       spellCheckConfiguration == null ||
    //       spellCheckConfiguration == const SpellCheckConfiguration.disabled() ||
    //       spellCheckConfiguration.misspelledTextStyle != null,
    //       'spellCheckConfiguration must specify a misspelledTextStyle if spell check behavior is desired',
    //    );
    //    _strutStyle = strutStyle;
    //    keyboardType = keyboardType ?? _inferKeyboardType(autofillHints: autofillHints, maxLines: maxLines);
    //    inputFormatters = maxLines == 1
    //        ? <TextInputFormatter>[
    //            FilteringTextInputFormatter.singleLineFormatter,
    //            ...inputFormatters ?? const Iterable<TextInputFormatter>.empty(),
    //          ]
    //        : inputFormatters;
    //    showCursor = showCursor ?? !readOnly;
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
  final TextCapitalization textCapitalization;
  final Brightness keyboardAppearance;
  final Color? selectionColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool enableSuggestions;
  final bool autocorrect;
  final UndoHistoryController? undoController;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final TextMagnifierConfiguration magnifierConfiguration;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final bool enableIMEPersonalizedLearning;
  final bool scribbleEnabled;
  final ToolbarOptions? toolbarOptions;
  final Color? autocorrectionTextRectColor;
  final bool enableInteractiveSelection;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final bool paintCursorAboveText;
  final Offset? cursorOffset;
  final bool cursorOpacityAnimates;
  final bool rendererIgnoresPointer;
  final TextDirection? textDirection;
  final bool? showCursor;

  @override
  State<NativeInput> createState() => _NativeInputState();
}

class _NativeInputState extends State<NativeInput> {
  late html.HtmlElement inputEl;
  html.InputElement? _inputElement;
  html.TextAreaElement? _textAreaElement;
  double sizedBoxHeight = 24;
  TextDirection get _textDirection =>
      widget.textDirection ??
      TextDirection.ltr; // Should this default to Directionality.of(context)?

  @override
  void initState() {
    super.initState();

    // create input element + init styling

    // conditionally create <textarea> or <input>
    if (widget.maxLines > 1) {
      _textAreaElement = html.TextAreaElement();
      _textAreaElement!.rows = widget.maxLines;
      _textAreaElement!.readOnly = widget.readOnly;
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
      ..setProperty(
          'caret-color',
          widget.showCursor == true
              ? colorToCss(widget.cursorColor)
              : 'transparent')
      ..outline = 'none'
      ..border = 'none'
      ..padding = '0'
      ..textAlign = textAlignToCssValue(widget.textAlign, _textDirection)
      ..pointerEvents = widget.rendererIgnoresPointer ? 'none' : 'auto'
      ..direction = _textDirection.name;

    // debug
    if (widget.obscureText) {
      _inputElement!.style.border = '1px solid red'; // debug
    }

    if (widget.selectionColor != null) {
      /*
        Needs the following code in engine
          sheet.insertRule('''
            $cssSelectorPrefix flt-glass-pane {
              --selection-background: #000000; 
            }
          ''', sheet.cssRules.length);

          sheet.insertRule('''
            $cssSelectorPrefix .customInputSelection::selection {
              background-color: var(--selection-background);
            }
          ''', sheet.cssRules.length);
      */
      // There is no easy way to modify pseudoclasses via js. We are accomplishing this
      // here via modifying a css var that is responsible for this ::selection style
      html.document.querySelector('flt-glass-pane')!.style.setProperty(
          '--selection-background', colorToCss(widget.selectionColor!));

      // To ensure we're only modifying selection on this specific input, we attach a custom class
      // instead of adding a blanket rule for all inputs.
      inputEl.classes.add('customInputSelection');
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
      // need to reset the css var color in case it was changed from
      // another instance
      html.document.querySelector('flt-glass-pane')!.style.setProperty(
          '--selection-background', colorToCss(widget.selectionColor!));
      widget.focusNode.requestFocus();
    });

    inputEl.onBlur.listen((e) {
      widget.focusNode.unfocus();
    });

    // hacky implementation, but don't know of a non-JS solution to disable
    // selection while keeping the input enabled for mouse + key events.
    // We don't add the listener if readOnly is set because the readOnly attribute
    // will take care of the disabled behavior
    if (widget.enableInteractiveSelection == false && !widget.readOnly) {
      inputEl.onSelect.listen((event) {
        _inputElement!.selectionStart = _inputElement!.selectionEnd;
      });
    }

    // register platform view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(widget.viewType, (int viewId) => inputEl);

    // add listeners for controller and focus
    widget.controller.addListener(_controllerListener);
    widget.focusNode.addListener(_focusListener);

    // handle autofocus, need to wait for platform view to be added to DOM
    if (widget.autofocus) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        inputEl.focus();
      });
    }

    // calculate box size based on specified lines
    sizedBoxHeight *= widget.maxLines;

    setAutocapitalizeAttribute();

    inputEl.setAttribute(
        'autocorrect', widget.autocorrect == true ? 'on' : 'off');
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

    return cssProperties.join('; ');
  }

  /// NOTE: Taken from engine
  /// Sets `autocapitalize` attribute on input elements.
  ///
  /// This attribute is only available for mobile browsers.
  ///
  /// Note that in mobile browsers the onscreen keyboards provide sentence
  /// level capitalization as default as apposed to no capitalization on desktop
  /// browser.
  ///
  /// See: https://developers.google.com/web/updates/2015/04/autocapitalize
  /// https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/autocapitalize
  void setAutocapitalizeAttribute() {
    String autocapitalize = '';
    switch (widget.textCapitalization) {
      case TextCapitalization.words:
        // TODO(mdebbar): There is a bug for `words` level capitalization in IOS now.
        // For now go back to default. Remove the check after bug is resolved.
        // https://bugs.webkit.org/show_bug.cgi?id=148504
        // TODO add browser engines
        // if (browserEngine == BrowserEngine.webkit) {
        //   autocapitalize = 'sentences';
        // } else {
        //   autocapitalize = 'words';
        // }
        autocapitalize = 'words';
      case TextCapitalization.characters:
        autocapitalize = 'characters';
      case TextCapitalization.sentences:
        autocapitalize = 'sentences';
      case TextCapitalization.none:
      default:
        autocapitalize = 'off';
        break;
    }
    if (widget.maxLines > 1) {
      _textAreaElement!.autocapitalize = autocapitalize;
    } else {
      _inputElement!.autocapitalize = autocapitalize;
    }
  }

  /// NOTE: Taken from engine.
  /// Converts [align] to its corresponding CSS value.
  ///
  /// This value is used as the "text-align" CSS property, e.g.:
  ///
  /// ```css
  /// text-align: right;
  /// ```
  String textAlignToCssValue(
      ui.TextAlign? align, ui.TextDirection textDirection) {
    switch (align) {
      case ui.TextAlign.left:
        return 'left';
      case ui.TextAlign.right:
        return 'right';
      case ui.TextAlign.center:
        return 'center';
      case ui.TextAlign.justify:
        return 'justify';
      case ui.TextAlign.end:
        switch (textDirection) {
          case ui.TextDirection.ltr:
            return 'end';
          case ui.TextDirection.rtl:
            return 'left';
        }
      case ui.TextAlign.start:
        switch (textDirection) {
          case ui.TextDirection.ltr:
            return ''; // it's the default
          case ui.TextDirection.rtl:
            return 'right';
        }
      case null:
        // If align is not specified return default.
        return '';
    }
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
          height: sizedBoxHeight,
          child: HtmlElementView(
            viewType: widget.viewType,
            // can pass in creationParams (map of things)
          )),
    );
  }
}

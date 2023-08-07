// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui; // change to ui_web when you update
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/widgets.dart';

import 'autofill_hint.dart';

/*
  Problems: getting the height to scale with the content.   
*/

/// The web implementation of the `NativeInput` widget.
class NativeInput extends StatefulWidget {
  NativeInput({
    super.key,
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
    this.minLines, // TODO: interaction between this and maxlines, can we do it with a textarea?
    this.textCapitalization = TextCapitalization.none,
    this.keyboardAppearance = Brightness.light, // not supported on web
    this.selectionColor,
    this.cursorWidth = 2.0, // not supported on web
    this.cursorHeight, // not supported on web
    this.cursorRadius, // not supported on web
    this.enableSuggestions = true, // not supported on web
    this.autocorrect = true, // Safari only
    this.undoController, // web handles its own undo
    SmartDashesType? smartDashesType, // not supported on web (ios only?)
    SmartQuotesType? smartQuotesType, // not supported on web (ios only?)
    this.magnifierConfiguration =
        TextMagnifierConfiguration.disabled, // not supported on web
    this.spellCheckConfiguration, // not supported on web
    this.enableIMEPersonalizedLearning = true, // not supported on web
    this.scribbleEnabled = true, // possibly not supported on web?
    this.textInputAction, // keyboard label is correct, TODO: need to implement behavior
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
      'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    ToolbarOptions? toolbarOptions,
    this.autocorrectionTextRectColor,
    bool? enableInteractiveSelection,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight, // not supported on web
    this.selectionWidthStyle = ui.BoxWidthStyle.tight, // not supported on web
    this.paintCursorAboveText = false, // not supported on web
    this.cursorOpacityAnimates = false, // not supported on web
    this.cursorOffset, // not supported on web,
    this.rendererIgnoresPointer = false,
    this.textDirection,
    bool? showCursor,
    this.autofillHints = const <String>[],
    this.autofillClient, // not supported on web (browser handles autofill)
    StrutStyle? strutStyle, // not supported on web (not 100% sure)
    this.locale, // not supported on web (lang attribute?)
    this.showSelectionHandles = false, // not supported on web
    this.textScaleFactor,
    this.forceLine = true, // not supported on web (not 100% sure)
    this.expands = false, // web behavior seems to always expand?
    this.textHeightBehavior, // TODO: not sure how to implement
    this.textWidthBasis =
        TextWidthBasis.parent, // not sure if this can be supported on web
    TextInputType? keyboardType,
    this.clipBehavior = Clip.hardEdge, // TODO: should I use overflow here?
    this.restorationId,
    this.selectionControls, // not sure if this makes sense on web
    this.onEditingComplete, // TODO implement
    this.onSubmitted,
    this.onAppPrivateCommand,
    this.onSelectionChanged,
    this.onSelectionHandleTapped,
    this.onTapOutside,
  })  : assert(obscuringCharacter.length == 1),
        smartDashesType = smartDashesType ??
            (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
        smartQuotesType = smartQuotesType ??
            (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
        assert(minLines == null || minLines > 0),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          "minLines can't be greater than maxLines",
        ),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true.',
        ),
        _strutStyle = strutStyle,
        keyboardType = keyboardType ??
            _inferKeyboardType(
                autofillHints: autofillHints, maxLines: maxLines),
        showCursor = showCursor ?? !readOnly,
        enableInteractiveSelection =
            enableInteractiveSelection ?? (!readOnly || !obscureText),
        toolbarOptions = null, // deprecated?
        viewType = '__webNativeInputViewType__${const Uuid().v4()}';

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
  final int? maxLines;
  final int? minLines;
  final TextCapitalization textCapitalization;
  final Brightness keyboardAppearance;
  final Color? selectionColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final bool enableSuggestions;
  final bool autocorrect;
  final UndoHistoryController? undoController;
  final SmartDashesType smartDashesType;
  final SmartQuotesType smartQuotesType;
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
  final bool showCursor;
  final Iterable<String> autofillHints;
  final AutofillClient? autofillClient;
  final Locale? locale;
  final bool showSelectionHandles;
  final double? textScaleFactor;
  final bool forceLine;
  final TextInputType keyboardType;
  final bool expands;
  final TextHeightBehavior? textHeightBehavior;
  final TextWidthBasis textWidthBasis;
  final Clip clipBehavior;
  final String? restorationId;
  final TextSelectionControls? selectionControls;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final AppPrivateCommandCallback? onAppPrivateCommand;
  final SelectionChangedCallback? onSelectionChanged;
  final VoidCallback? onSelectionHandleTapped;
  final TapRegionCallback? onTapOutside;

  // Infer the keyboard type of an `EditableText` if it's not specified.
  static TextInputType _inferKeyboardType({
    required Iterable<String>? autofillHints,
    required int? maxLines,
  }) {
    if (autofillHints == null || autofillHints.isEmpty) {
      return maxLines == 1 ? TextInputType.text : TextInputType.multiline;
    }

    final String effectiveHint = autofillHints.first;

    if (maxLines != 1) {
      return TextInputType.multiline;
    }

    const Map<String, TextInputType> inferKeyboardType =
        <String, TextInputType>{
      AutofillHints.addressCity: TextInputType.streetAddress,
      AutofillHints.addressCityAndState: TextInputType.streetAddress,
      AutofillHints.addressState: TextInputType.streetAddress,
      AutofillHints.birthday: TextInputType.datetime,
      AutofillHints.birthdayDay: TextInputType.datetime,
      AutofillHints.birthdayMonth: TextInputType.datetime,
      AutofillHints.birthdayYear: TextInputType.datetime,
      AutofillHints.countryCode: TextInputType.number,
      AutofillHints.countryName: TextInputType.text,
      AutofillHints.creditCardExpirationDate: TextInputType.datetime,
      AutofillHints.creditCardExpirationDay: TextInputType.datetime,
      AutofillHints.creditCardExpirationMonth: TextInputType.datetime,
      AutofillHints.creditCardExpirationYear: TextInputType.datetime,
      AutofillHints.creditCardFamilyName: TextInputType.name,
      AutofillHints.creditCardGivenName: TextInputType.name,
      AutofillHints.creditCardMiddleName: TextInputType.name,
      AutofillHints.creditCardName: TextInputType.name,
      AutofillHints.creditCardNumber: TextInputType.number,
      AutofillHints.creditCardSecurityCode: TextInputType.number,
      AutofillHints.creditCardType: TextInputType.text,
      AutofillHints.email: TextInputType.emailAddress,
      AutofillHints.familyName: TextInputType.name,
      AutofillHints.fullStreetAddress: TextInputType.streetAddress,
      AutofillHints.gender: TextInputType.text,
      AutofillHints.givenName: TextInputType.name,
      AutofillHints.impp: TextInputType.url,
      AutofillHints.jobTitle: TextInputType.text,
      AutofillHints.language: TextInputType.text,
      AutofillHints.location: TextInputType.streetAddress,
      AutofillHints.middleInitial: TextInputType.name,
      AutofillHints.middleName: TextInputType.name,
      AutofillHints.name: TextInputType.name,
      AutofillHints.namePrefix: TextInputType.name,
      AutofillHints.nameSuffix: TextInputType.name,
      AutofillHints.newPassword: TextInputType.text,
      AutofillHints.newUsername: TextInputType.text,
      AutofillHints.nickname: TextInputType.text,
      AutofillHints.oneTimeCode: TextInputType.text,
      AutofillHints.organizationName: TextInputType.text,
      AutofillHints.password: TextInputType.text,
      AutofillHints.photo: TextInputType.text,
      AutofillHints.postalAddress: TextInputType.streetAddress,
      AutofillHints.postalAddressExtended: TextInputType.streetAddress,
      AutofillHints.postalAddressExtendedPostalCode: TextInputType.number,
      AutofillHints.postalCode: TextInputType.number,
      AutofillHints.streetAddressLevel1: TextInputType.streetAddress,
      AutofillHints.streetAddressLevel2: TextInputType.streetAddress,
      AutofillHints.streetAddressLevel3: TextInputType.streetAddress,
      AutofillHints.streetAddressLevel4: TextInputType.streetAddress,
      AutofillHints.streetAddressLine1: TextInputType.streetAddress,
      AutofillHints.streetAddressLine2: TextInputType.streetAddress,
      AutofillHints.streetAddressLine3: TextInputType.streetAddress,
      AutofillHints.sublocality: TextInputType.streetAddress,
      AutofillHints.telephoneNumber: TextInputType.phone,
      AutofillHints.telephoneNumberAreaCode: TextInputType.phone,
      AutofillHints.telephoneNumberCountryCode: TextInputType.phone,
      AutofillHints.telephoneNumberDevice: TextInputType.phone,
      AutofillHints.telephoneNumberExtension: TextInputType.phone,
      AutofillHints.telephoneNumberLocal: TextInputType.phone,
      AutofillHints.telephoneNumberLocalPrefix: TextInputType.phone,
      AutofillHints.telephoneNumberLocalSuffix: TextInputType.phone,
      AutofillHints.telephoneNumberNational: TextInputType.phone,
      AutofillHints.transactionAmount:
          TextInputType.numberWithOptions(decimal: true),
      AutofillHints.transactionCurrency: TextInputType.text,
      AutofillHints.url: TextInputType.url,
      AutofillHints.username: TextInputType.text,
    };

    return inferKeyboardType[effectiveHint] ?? TextInputType.text;
  }

  StrutStyle get strutStyle {
    if (_strutStyle == null) {
      return StrutStyle.fromTextStyle(style, forceStrutHeight: true);
    }
    return _strutStyle!.inheritFromTextStyle(style);
  }

  final StrutStyle? _strutStyle;

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
  late final int _maxLines;

  @override
  void initState() {
    super.initState();

    _maxLines = widget.maxLines ?? 1;

    // create input element + init styling

    // conditionally create <textarea> or <input>
    if (_maxLines > 1) {
      _textAreaElement = html.TextAreaElement();
      _textAreaElement!.rows = _maxLines;
      _textAreaElement!.readOnly = widget.readOnly;
      inputEl = _textAreaElement!;
    } else {
      _inputElement = html.InputElement();
      _inputElement!.readOnly = widget.readOnly;

      if (widget.obscureText) {
        _inputElement!.type = 'password';
      } else {
        final Map<String, String> attributes =
            getKeyboardTypeAttributes(widget.keyboardType);
        _inputElement!.type = attributes['type'];
        _inputElement!.inputMode = attributes['inputmode'];
      }

      if (widget.autofillHints.isNotEmpty) {
        // browsers can only use one autocomplete attribute
        final String autocomplete = _getAutocompleteAttribute(widget.autofillHints.first);
        _inputElement!.id = autocomplete;
        _inputElement!.name = autocomplete;
        _inputElement!.autocomplete = autocomplete;
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
      ..direction = _textDirection.name
      ..lineHeight = '1.5'; // can this be modified by a property?

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

    if (widget.textScaleFactor != null) {
      inputEl.style.fontSize =
          scaleFontSize(inputEl.style.fontSize, widget.textScaleFactor!);
      sizedBoxHeight *= widget.textScaleFactor!;
    }

    // listen for events
    inputEl.onInput.listen((e) {
      final String currentText = getElementValue();
      widget.controller.text = currentText;

      if (widget.onChanged != null) {
        widget.onChanged!.call(currentText);
      }
    });

    inputEl.onFocus.listen((e) {
      widget.focusNode.requestFocus();

      if (widget.selectionColor != null) {
        // Since we're relying on a CSS variable to handle selection background, we
        // run into an issue when there are multiple inputs with multiple selection background
        // values. In that case, the variable is always set to whatever the last rendered input's selection
        // background value was set to.  To fix this, we update that CSS variable to the currently focused
        // element's selection color value.
        html.document.querySelector('flt-glass-pane')!.style.setProperty(
            '--selection-background', colorToCss(widget.selectionColor!));
      }
    });

    inputEl.onBlur.listen((e) {
      widget.focusNode.unfocus();
    });

    inputEl.onKeyDown.listen((event) {
      if (event.keyCode == html.KeyCode.ENTER) {
        final TextInputAction defaultTextInputAction =
            _maxLines > 1 ? TextInputAction.newline : TextInputAction.done;
        performAction(widget.textInputAction ?? defaultTextInputAction);
      }
    });

    // we can only do 'select' events which fire after selection, but not
    // when carets change positions.  This is slightly different than the 
    // selectionChange behavior on Flutter, which also fires when the caret
    // changes.  
    inputEl.onSelect.listen((event) {
      final int baseOffset = (_maxLines > 1
              ? _textAreaElement!.selectionStart
              : _inputElement!.selectionStart) ??
          0;
      final int extentOffset = (_maxLines > 1
              ? _textAreaElement!.selectionEnd
              : _inputElement!.selectionEnd) ??
          0;
      _handleSelectionChanged(
          TextSelection(baseOffset: baseOffset, extentOffset: extentOffset),
          null); // TODO figure out how to determine cause or if this is even needed on web.

      // hacky implementation, but don't know of a non-JS solution to disable
      // selection while keeping the input enabled for mouse + key events.
      // We adjust the selection if readOnly is set because the readOnly attribute
      // will take care of the disabled behavior
      if (widget.enableInteractiveSelection == false && !widget.readOnly) {
        _inputElement!.selectionStart = _inputElement!.selectionEnd;
      }
    });

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
    // TODO: can we make this better?
    sizedBoxHeight *= _maxLines;

    setAutocapitalizeAttribute();

    inputEl.setAttribute(
        'autocorrect', widget.autocorrect == true ? 'on' : 'off');

    if (widget.textInputAction != null) {
      final String? enterKeyHint = getEnterKeyHint(widget.textInputAction!);

      if (enterKeyHint != null) {
        inputEl.setAttribute('enterkeyhint', enterKeyHint);
      }
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
    return (_maxLines > 1 ? _textAreaElement!.value : _inputElement!.value)
        as String;
  }

  void setElementValue(String value) {
    if (_maxLines > 1) {
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
      cssProperties.add('font-family: "${style.fontFamily}"');
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
  /// TODO: make more functional, set autocap attr outside of function using return val
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
    if (_maxLines > 1) {
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

  /// Takes a font size read from the style property (e.g. '16px) and scales it
  /// by some factor. Returns the scaled font size in a CSS friendly format.
  String scaleFontSize(String fontSize, double textScaleFactor) {
    assert(fontSize.endsWith('px'));
    final String strippedFontSize = fontSize.replaceAll('px', '');
    final double parsedFontSize = double.parse(strippedFontSize);
    final int scaledFontSize = (parsedFontSize * textScaleFactor).round();

    return '${scaledFontSize}px';
  }

  Map<String, String> getKeyboardTypeAttributes(TextInputType inputType) {
    final bool? isDecimal = inputType.decimal;

    switch (inputType) {
      case TextInputType.number:
        return {
          'type': 'number',
          'inputmode': isDecimal == true ? 'decimal' : 'numeric'
        };
      case TextInputType.phone:
        return {'type': 'tel', 'inputmode': 'tel'};
      case TextInputType.emailAddress:
        return {'type': 'email', 'inputmode': 'email'};
      case TextInputType.url:
        return {'type': 'url', 'inputmode': 'url'};
      case TextInputType.none:
        return {'type': 'text', 'inputmode': 'none'};
      case TextInputType.text:
        return {'type': 'text', 'inputmode': 'text'};
      default:
        return {'type': 'text', 'inputmode': 'text'};
    }
  }

  String? getEnterKeyHint(TextInputAction inputAction) {
    switch (inputAction) {
      case TextInputAction.continueAction:
      case TextInputAction.next:
        return 'next';
      case TextInputAction.previous:
        return 'previous';
      case TextInputAction.done:
        return 'done';
      case TextInputAction.go:
        return 'go';
      case TextInputAction.newline:
        return 'enter';
      case TextInputAction.search:
        return 'search';
      case TextInputAction.send:
        return 'send';
      case TextInputAction.emergencyCall:
      case TextInputAction.join:
      case TextInputAction.none:
      case TextInputAction.route:
      case TextInputAction.unspecified:
      default:
        return null;
    }
  }

  // override if we extend
  void performAction(TextInputAction action) {
    switch (action) {
      case TextInputAction.newline:
        // If this is a multiline EditableText, do nothing for a "newline"
        // action; The newline is already inserted. Otherwise, finalize
        // editing.
        if (_maxLines == 1) {
          _finalizeEditing(action, shouldUnfocus: true);
        }
      case TextInputAction.done:
      case TextInputAction.go:
      case TextInputAction.next:
      case TextInputAction.previous:
      case TextInputAction.search:
      case TextInputAction.send:
        _finalizeEditing(action, shouldUnfocus: true);
      case TextInputAction.continueAction:
      case TextInputAction.emergencyCall:
      case TextInputAction.join:
      case TextInputAction.none:
      case TextInputAction.route:
      case TextInputAction.unspecified:
        // Finalize editing, but don't give up focus because this keyboard
        // action does not imply the user is done inputting information.
        _finalizeEditing(action, shouldUnfocus: false);
    }
  }

  void _finalizeEditing(TextInputAction action, {required bool shouldUnfocus}) {
    // Take any actions necessary now that the user has completed editing.
    if (widget.onEditingComplete != null) {
      try {
        widget.onEditingComplete!();
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'widgets',
          context:
              ErrorDescription('while calling onEditingComplete for $action'),
        ));
      }
    } else {
      // Default behavior if the developer did not provide an
      // onEditingComplete callback: Finalize editing and remove focus, or move
      // it to the next/previous field, depending on the action.
      // widget.controller.clearComposing();
      if (shouldUnfocus) {
        switch (action) {
          case TextInputAction.none:
          case TextInputAction.unspecified:
          case TextInputAction.done:
          case TextInputAction.go:
          case TextInputAction.search:
          case TextInputAction.send:
          case TextInputAction.continueAction:
          case TextInputAction.join:
          case TextInputAction.route:
          case TextInputAction.emergencyCall:
          case TextInputAction.newline:
            widget.focusNode.unfocus();
          case TextInputAction.next:
            widget.focusNode.nextFocus();
          case TextInputAction.previous:
            widget.focusNode.previousFocus();
        }
      }
    }

    final ValueChanged<String>? onSubmitted = widget.onSubmitted;
    if (onSubmitted == null) {
      return;
    }

    // Invoke optional callback with the user's submitted content.
    try {
      onSubmitted(getElementValue());
    } catch (exception, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'widgets',
        context: ErrorDescription('while calling onSubmitted for $action'),
      ));
    }

    // If `shouldUnfocus` is true, the text field should no longer be focused
    // after the microtask queue is drained. But in case the developer cancelled
    // the focus change in the `onSubmitted` callback by focusing this input
    // field again, reset the soft keyboard.
    // See https://github.com/flutter/flutter/issues/84240.
    //
    // `_restartConnectionIfNeeded` creates a new TextInputConnection to replace
    // the current one. This on iOS switches to a new input view and on Android
    // restarts the input method, and in both cases the soft keyboard will be
    // reset.
    // if (shouldUnfocus) {
    //   _scheduleRestartConnection();
    // }
  }

  void _handleSelectionChanged(
      TextSelection selection, SelectionChangedCause? cause) {
    try {
      widget.onSelectionChanged?.call(selection, cause);
    } catch (exception, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'widgets',
        context:
            ErrorDescription('while calling onSelectionChanged for $cause'),
      ));
    }
  }

    /// The default behavior used if [onTapOutside] is null.
  /// TODO: Fix this once we move to framework  
  /// The `event` argument is the [PointerDownEvent] that caused the notification.
  void _defaultOnTapOutside(PointerDownEvent event) {
    /// The focus dropping behavior is only present on desktop platforms
    /// and mobile browsers.

    widget.focusNode.unfocus();
  }
  
  String _getAutocompleteAttribute(String autofillHint) {
    switch(autofillHint) {
      case AutofillHints.birthday: 
        return 'bday';
      case AutofillHints.birthdayDay:
        return 'bday-day';
      case AutofillHints.birthdayMonth:
        return 'bday-month';
      case AutofillHints.birthdayYear:
        return 'bday-year';
      case AutofillHints.countryCode:
        return 'country';
      case AutofillHints.countryName:
        return 'country-name';
      case AutofillHints.creditCardExpirationDate:
        return 'cc-exp';
      case AutofillHints.creditCardExpirationMonth:
        return 'cc-exp-month';
      case AutofillHints.creditCardExpirationYear:
        return 'cc-exp-year';
      case AutofillHints.creditCardFamilyName:
        return 'cc-family-name';
      case AutofillHints.creditCardGivenName:
        return 'cc-given-name';
      case AutofillHints.creditCardMiddleName:
        return 'cc-additional-name';
      case AutofillHints.creditCardName:
        return 'cc-name';
      case AutofillHints.creditCardNumber:
        return 'cc-number';
      case AutofillHints.creditCardSecurityCode:
        return 'cc-csc';
      case AutofillHints.creditCardType:
        return 'cc-type';
      case AutofillHints.email:
        return 'email';
      case AutofillHints.familyName:
        return 'family-name';
      case AutofillHints.fullStreetAddress:
        return 'street-address';
      case AutofillHints.gender:
        return 'sex';
      case AutofillHints.givenName:
        return 'given-name';
      case AutofillHints.impp:
        return 'impp';
      case AutofillHints.jobTitle:
        return 'organization-title';
      case AutofillHints.middleName:
        return 'middleName';
      case AutofillHints.name:
        return 'name';
      case AutofillHints.namePrefix:
        return 'honorific-prefix';
      case AutofillHints.nameSuffix:
        return 'honorific-suffix';
      case AutofillHints.newPassword:
        return 'new-password';
      case AutofillHints.nickname:
        return 'nickname';
      case AutofillHints.oneTimeCode:
        return 'one-time-code';
      case AutofillHints.organizationName:
        return 'organization';
      case AutofillHints.password:
        return 'current-password';
      case AutofillHints.photo:
        return 'photo';
      case AutofillHints.postalCode:
        return 'postal-code';
      case AutofillHints.streetAddressLevel1:
        return 'address-level1';
      case AutofillHints.streetAddressLevel2:
        return 'address-level2';
      case AutofillHints.streetAddressLevel3:
        return 'address-level3';
      case AutofillHints.streetAddressLevel4:
        return 'address-level4';
      case AutofillHints.streetAddressLine1:
        return 'address-line1';
      case AutofillHints.streetAddressLine2:
        return 'address-line2';
      case AutofillHints.streetAddressLine3:
        return 'address-line3';
      case AutofillHints.telephoneNumber:
        return 'tel';
      case AutofillHints.telephoneNumberAreaCode:
        return 'tel-area-code';
      case AutofillHints.telephoneNumberCountryCode:
        return 'tel-country-code';
      case AutofillHints.telephoneNumberExtension:
        return 'tel-extension';
      case AutofillHints.telephoneNumberLocal:
        return 'tel-local';
      case AutofillHints.telephoneNumberLocalPrefix:
        return 'tel-local-prefix';
      case AutofillHints.telephoneNumberLocalSuffix:
        return 'tel-local-suffix';
      case AutofillHints.telephoneNumberNational:
        return 'tel-national';
      case AutofillHints.transactionAmount:
        return 'transaction-amount';
      case AutofillHints.transactionCurrency:
        return 'transaction-currency';
      case AutofillHints.url:
        return 'url';
      case AutofillHints.username:
        return 'username';
      default:
        return autofillHint;
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

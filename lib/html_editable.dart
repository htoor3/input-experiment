// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui; // change to ui_web when you update
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/widgets.dart';

class HtmlEditable extends StatefulWidget {
  HtmlEditable({
    super.key,
    required this.inlineSpan,
    required this.value,
    required this.startHandleLayerLink,
    required this.endHandleLayerLink,
    required this.cursorColor,
    this.backgroundCursorColor,
    required this.showCursor,
    required this.forceLine,
    required this.readOnly,
    this.textHeightBehavior,
    required this.textWidthBasis,
    required this.hasFocus,
    required this.maxLines,
    this.minLines,
    required this.expands,
    this.strutStyle,
    this.selectionColor,
    required this.textScaler,
    required this.textAlign,
    required this.textDirection,
    this.locale,
    required this.obscuringCharacter,
    required this.obscureText,
    required this.offset,
    this.rendererIgnoresPointer = false,
    required this.cursorWidth,
    this.cursorHeight,
    this.cursorRadius,
    required this.cursorOffset,
    required this.paintCursorAboveText,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.enableInteractiveSelection = true,
    required this.textSelectionDelegate,
    required this.devicePixelRatio,
    this.promptRectRange,
    this.promptRectColor,
    required this.clipBehavior,
    this.keyboardType = TextInputType.text, // _Editable doesn't have
    this.autofillHints = const <String>[], // _Editable doesn't have
    this.textCapitalization = TextCapitalization.none, // _Editable doesn't have
    this.autocorrect = true, // _Editable doesn't have
    this.textInputAction, // _Editable doesn't have
  }) : viewType = '__webHtmlEditableViewType__${const Uuid().v4()}';

  late final String viewType;
  final InlineSpan inlineSpan;
  final TextEditingValue value;
  final Color cursorColor;
  final LayerLink startHandleLayerLink;
  final LayerLink endHandleLayerLink;
  final Color? backgroundCursorColor;
  final ValueNotifier<bool> showCursor;
  final bool forceLine;
  final bool readOnly;
  final bool hasFocus;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final StrutStyle? strutStyle;
  final Color? selectionColor;
  final TextScaler textScaler;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale? locale;
  final String obscuringCharacter;
  final bool obscureText;
  final TextHeightBehavior? textHeightBehavior;
  final TextWidthBasis textWidthBasis;
  final ViewportOffset offset;
  final bool rendererIgnoresPointer;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Offset cursorOffset;
  final bool paintCursorAboveText;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final bool enableInteractiveSelection;
  final TextSelectionDelegate textSelectionDelegate;
  final double devicePixelRatio;
  final TextRange? promptRectRange;
  final Color? promptRectColor;
  final Clip clipBehavior;
  final TextInputType keyboardType;
  final Iterable<String> autofillHints;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final TextInputAction? textInputAction;

  @override
  State<HtmlEditable> createState() => _HtmlEditableState();
}

class _HtmlEditableState extends State<HtmlEditable> {
  late html.HtmlElement inputEl;
  html.InputElement? _inputElement;
  html.TextAreaElement? _textAreaElement;
  double sizedBoxHeight = 24;
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
        final String autocomplete =
            _getAutocompleteAttribute(widget.autofillHints.first);
        _inputElement!.id = autocomplete;
        _inputElement!.name = autocomplete;
        _inputElement!.autocomplete = autocomplete;
      }

      inputEl = _inputElement!;
    }

    // style based on TextStyle
    // inputEl.style.cssText = textStyleToCss(widget.style); //TODO

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
      ..textAlign = textAlignToCssValue(widget.textAlign, widget.textDirection)
      ..pointerEvents = widget.rendererIgnoresPointer ? 'none' : 'auto'
      ..direction = widget.textDirection.name
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

    // TODO
    // if (widget.textScaleFactor != null) {
    //   inputEl.style.fontSize =
    //       scaleFontSize(inputEl.style.fontSize, widget.textScaleFactor!);
    //   sizedBoxHeight *= widget.textScaleFactor!;
    // }

    // listen for events
    // inputEl.onInput.listen((e) {
    //   final String currentText = getElementValue();
    //   widget.controller.text = currentText;

    //   if (widget.onChanged != null) {
    //     widget.onChanged!.call(currentText);
    //   }
    // });

    inputEl.setAttribute('value', widget.value.text);

    // inputEl.onFocus.listen((e) {
    //   widget.focusNode.requestFocus();

    //   if (widget.selectionColor != null) {
    //     // Since we're relying on a CSS variable to handle selection background, we
    //     // run into an issue when there are multiple inputs with multiple selection background
    //     // values. In that case, the variable is always set to whatever the last rendered input's selection
    //     // background value was set to.  To fix this, we update that CSS variable to the currently focused
    //     // element's selection color value.
    //     html.document.querySelector('flt-glass-pane')!.style.setProperty(
    //         '--selection-background', colorToCss(widget.selectionColor!));
    //   }
    // });

    // inputEl.onBlur.listen((e) {
    //   widget.focusNode.unfocus();
    // });

    // inputEl.onKeyDown.listen((event) {
    //   if (event.keyCode == html.KeyCode.ENTER) {
    //     final TextInputAction defaultTextInputAction =
    //         _maxLines > 1 ? TextInputAction.newline : TextInputAction.done;
    //     performAction(widget.textInputAction ?? defaultTextInputAction);
    //   }
    // });

    // we can only do 'select' events which fire after selection, but not
    // when carets change positions.  This is slightly different than the
    // selectionChange behavior on Flutter, which also fires when the caret
    // changes.
    // inputEl.onSelect.listen((event) {
    //   final int baseOffset = (_maxLines > 1
    //           ? _textAreaElement!.selectionStart
    //           : _inputElement!.selectionStart) ??
    //       0;
    //   final int extentOffset = (_maxLines > 1
    //           ? _textAreaElement!.selectionEnd
    //           : _inputElement!.selectionEnd) ??
    //       0;
    //   _handleSelectionChanged(
    //       TextSelection(baseOffset: baseOffset, extentOffset: extentOffset),
    //       null); // TODO figure out how to determine cause or if this is even needed on web.

    //   // hacky implementation, but don't know of a non-JS solution to disable
    //   // selection while keeping the input enabled for mouse + key events.
    //   // We adjust the selection if readOnly is set because the readOnly attribute
    //   // will take care of the disabled behavior
    //   if (widget.enableInteractiveSelection == false && !widget.readOnly) {
    //     _inputElement!.selectionStart = _inputElement!.selectionEnd;
    //   }
    // });

    // register platform view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(widget.viewType, (int viewId) => inputEl);

    // add listeners for controller and focus
    // widget.controller.addListener(_controllerListener);
    // widget.focusNode.addListener(_focusListener);

    // handle autofocus, need to wait for platform view to be added to DOM
    // if (widget.autofocus) {
    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
    //     inputEl.focus();
    //   });
    // }

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

  // void _controllerListener() {
  //   final String text = widget.controller.text;
  //   setElementValue(text);
  // }

  // void _focusListener() {
  //   if (widget.focusNode.hasFocus) {
  //     inputEl.focus();
  //   } else {
  //     inputEl.blur();
  //   }
  // }

  @override
  void dispose() {
    print('disposed');
    // widget.controller.removeListener(_controllerListener);
    // widget.focusNode.removeListener(_focusListener);

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
  /// TODO
  // String scaleFontSize(String fontSize, double textScaleFactor) {
  //   assert(fontSize.endsWith('px'));
  //   final String strippedFontSize = fontSize.replaceAll('px', '');
  //   final double parsedFontSize = double.parse(strippedFontSize);
  //   final int scaledFontSize = (parsedFontSize * textScaleFactor).round();

  //   return '${scaledFontSize}px';
  // }

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
  // TODO
  // void _handleSelectionChanged(
  //     TextSelection selection, SelectionChangedCause? cause) {
  //   try {
  //     widget.onSelectionChanged?.call(selection, cause);
  //   } catch (exception, stack) {
  //     FlutterError.reportError(FlutterErrorDetails(
  //       exception: exception,
  //       stack: stack,
  //       library: 'widgets',
  //       context:
  //           ErrorDescription('while calling onSelectionChanged for $cause'),
  //     ));
  //   }
  // }

  String _getAutocompleteAttribute(String autofillHint) {
    switch (autofillHint) {
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
    return SizedBox(
          height: sizedBoxHeight,
          child: HtmlElementView(
            viewType: widget.viewType,
            // can pass in creationParams (map of things)
          ),
    );
  }
}
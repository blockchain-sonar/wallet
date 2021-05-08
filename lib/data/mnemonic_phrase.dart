import "dart:collection" show UnmodifiableListView;

import "package:freemework/freemework.dart" show InvalidOperationException;

enum MnemonicPhraseLength {
  SHORT,
  LONG,
}

class MnemonicPhrase {
  final MnemonicPhraseLength length;
  final UnmodifiableListView<String> words;

  factory MnemonicPhrase.parse(String mnemonicPhraseSentence) {
    return MnemonicPhrase(mnemonicPhraseSentence.split(_WORDS_SEPARATOR));
  }

  factory MnemonicPhrase(
    final List<String> words, [
    MnemonicPhraseLength? length,
  ]) {
    if (length == null) {
      switch (words.length) {
        case 12:
          length = MnemonicPhraseLength.SHORT;
          break;
        case 24:
          length = MnemonicPhraseLength.LONG;
          break;
        default:
          throw InvalidOperationException(
              "Wrong operation. A short mnemonic phrase should have exactly 12 or 24 words");
      }
    } else {
      if (length == MnemonicPhraseLength.SHORT && words.length != 12) {
        throw InvalidOperationException(
            "Wrong operation. A short mnemonic phrase should have exactly 12 words");
      }

      if (length == MnemonicPhraseLength.LONG && words.length != 24) {
        throw InvalidOperationException(
            "Wrong operation. A long mnemonic phrase should have exactly 24 words");
      }
    }
    return MnemonicPhrase._(length, UnmodifiableListView<String>(words));
  }

  String get sentence => this.words.join(_WORDS_SEPARATOR);

  static String _WORDS_SEPARATOR = " ";

  MnemonicPhrase._(this.length, this.words);
}

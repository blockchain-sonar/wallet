//
// Copyright 2021 Free TON Wallet Team
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

class TonDecimal {
  static final TonDecimal zero = TonDecimal._(BigInt.zero);

  static final BigInt _DELIMER = BigInt.from(10).pow(9);
  final BigInt _wrap;

  factory TonDecimal.parse(final String str) {
    final List<String> parts = str.split(".");
    if (parts.length > 2) {
      throw FormatException("Could not parse TonDecimal ${str}", str, 0);
    }

    BigInt integerPart;
    try {
      integerPart = BigInt.parse(parts[0], radix: 10);
    } catch (e) {
      if (e is FormatException) {
        throw FormatException(
            "Could not parse integer part of TonDecimal ${parts[0]}",
            parts[0],
            0);
      }
      throw e;
    }

    BigInt fractionalPart = BigInt.zero;
    if (parts.length == 2) {
      try {
        final String friendlyPart = parts[1].padRight(9, "0");
        fractionalPart = BigInt.parse(friendlyPart, radix: 10);
      } catch (e) {
        if (e is FormatException) {
          throw FormatException(
              "Could not parse fractional part TonDecimal ${parts[1]}",
              parts[1],
              0);
        }
        throw e;
      }
    }

    final BigInt nano = integerPart * _DELIMER + fractionalPart;

    if (nano == BigInt.zero) {
      return zero;
    }

    return TonDecimal._(nano);
  }
  factory TonDecimal.parseNanoDec(final String str) {
    try {
      final BigInt nano = BigInt.parse(str, radix: 10);

      if (nano == BigInt.zero) {
        return zero;
      }

      return TonDecimal._(nano);
    } catch (e) {
      if (e is FormatException) {
        throw FormatException(
            "Could not parse nano dec as TonDecimal ${str}", str, 0);
      }
      throw e;
    }
  }
  factory TonDecimal.parseNanoHex(final String str) {
    if (!str.startsWith("0x")) {
      throw FormatException(
          "Bad value. HEX TonDecimal should starts with '0x'.", str, 0);
    }
    final String friendlyStr = str.substring(2);
    try {
      final BigInt nano = BigInt.parse(friendlyStr, radix: 16);

      if (nano == BigInt.zero) {
        return zero;
      }

      return TonDecimal._(nano);
    } catch (e) {
      if (e is FormatException) {
        throw FormatException(
            "Could not parse nano hex as TonDecimal ${str}", str, 0);
      }
      throw e;
    }
  }

  TonDecimal operator +(TonDecimal other) {
    return TonDecimal._(this._wrap + other._wrap);
  }

  String get nanoDec => this._wrap.toRadixString(10);
  String get nanoHex => "0x${this._wrap.toRadixString(16)}";
  String get value {
    final BigInt integerPart = this._wrap ~/ _DELIMER;
    final BigInt fractionalPart = this._wrap.remainder(_DELIMER);

    final String integerPartStr = integerPart.toRadixString(10);
    final String fractionalPartStr =
        fractionalPart.toRadixString(10).padLeft(9, "0");

    assert(fractionalPartStr.length == 9);

    return "${integerPartStr}.${fractionalPartStr.substring(0, 3)} ${fractionalPartStr.substring(3, 6)} ${fractionalPartStr.substring(6)}";
  }

  @override
  String toString() => this.value;

  TonDecimal._(this._wrap);
}

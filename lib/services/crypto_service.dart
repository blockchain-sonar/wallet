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

import "dart:convert" show base64Decode, base64Encode, utf8;
import "dart:math" show Random;
import "dart:typed_data" show Uint8List;

import "package:freemework/freemework.dart" show FreemeworkException;
import "package:pointycastle/export.dart"
    show
        AESFastEngine,
        CBCBlockCipher,
        CipherParameters,
        HMac,
        KeyDerivator,
        KeyParameter,
        PBKDF2KeyDerivator,
        PKCS7Padding,
        PaddedBlockCipher,
        PaddedBlockCipherImpl,
        PaddedBlockCipherParameters,
        ParametersWithIV,
        Pbkdf2Parameters,
        SHA512Digest;

abstract class CryptoService {
  Encypter createEncypter(Uint8List encryptionKey);

  /// Password-Based Key Derivation Function helper
  /// https://en.wikipedia.org/wiki/PBKDF2
  ///
  /// [password] data to be derivated.
  ///
  /// [salt] is random 8-bytes. Will generate, if null.
  ///
  /// [iterations] number of derivation iterations. Will use random 128..512 value, if null.
  ///
  /// [keylen] desired key length. Default: 32.
  ///
  /// [digestAlgo] diggest algorithm is one of "sha256", "sha512". Default: "sha512".
  ///
  Future<DerivateResult> derivate(
    String password, {
    Uint8List? salt,
    int? iterations,
    int? keylen,
    String? digest,
  });
}

class DerivateResult {
  final Uint8List salt;
  final int iterations;
  final String digest;
  final Uint8List derivatedKey;
  DerivateResult(
      this.salt, this.iterations, this.digest, this.derivatedKey);
}

abstract class Encypter {
  Uint8List decryptBinary(Uint8List encryptedData);
  String decryptStringFromBas64(String encryptedDataBase64) {
    final Uint8List encryptedData = base64Decode(encryptedDataBase64);
    final Uint8List data = this.decryptBinary(encryptedData);
    final String originalString = utf8.decode(data, allowMalformed: false);
    return originalString;
  }
  Uint8List encryptBinary(Uint8List data);
  String encryptStringToBas64(String text) {
    final Uint8List data = Uint8List.fromList(utf8.encode(text));
    final Uint8List encryptedData = this.encryptBinary(data);
    final String encryptedDataBase64 = base64Encode(encryptedData);
    return encryptedDataBase64;
  }
}

class PointyCastleCryptoService extends CryptoService {
  @override
  Encypter createEncypter(Uint8List encryptionKey) {
    return _PointyCastleEncypter(encryptionKey);
  }

  @override
  Future<DerivateResult> derivate(
    String password, {
    Uint8List? salt,
    int? iterations,
    int? keylen,
    String? digest,
  }) {
    if (salt == null) {
      salt = Uint8List.fromList(
          List<int>.generate(32, (_) => _random.nextInt(256)));
    } else {
      if (salt.length != 32) {
        throw ArgumentError.value(
            salt, "salt", "Wrong salt value. Expected exactly 32 bytes.");
      }
    }

    if (iterations == null) {
      iterations = _random.nextInt(512 - 128) + 128;
    }

    if (keylen == null) {
      keylen = _DEFAULT_KEY_LEN;
    }

    if (digest == null) {
      digest = "sha512";
    }

    return _derivate(password,
        salt: salt,
        iterations: iterations,
        keylen: keylen,
        digest: digest);
  }

  Future<DerivateResult> _derivate(
    String password, {
    required Uint8List salt,
    required int iterations,
    required int keylen,
    required String digest,
  }) async {
    //final Pbkdf2Parameters para = Pbkdf2Parameters();
    //final KeyDerivator derivator = KeyDerivator("SHA-256/HMAC/PBKDF2");

    final Uint8List dataToDerivate = Uint8List.fromList(utf8.encode(password));
    //int inpOff;
    final Uint8List derivatedKey = Uint8List(keylen);
    //int outOff;

    final Pbkdf2Parameters params = Pbkdf2Parameters(salt, iterations, keylen);
    final KeyDerivator derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 64))
      ..init(params);
    final int derivedBytesCount =
        derivator.deriveKey(dataToDerivate, 0, derivatedKey, 0);

    if (derivedBytesCount != keylen) {
      throw FreemeworkException(
          "Unexpected response from underlaying library. PointyCastle method deriveKey returns unexpected value: ${derivedBytesCount}, while expeted same to keylen: ${keylen}");
    }

    final DerivateResult result = DerivateResult(
      salt,
      iterations,
      digest,
      derivatedKey,
    );

    return result;
  }
}

final Random _random = Random();
const int _DEFAULT_KEY_LEN = 32;

///
/// https://github.com/bcgit/pc-dart/blob/master/tutorials/aes-cbc.md
///
class _PointyCastleEncypter extends Encypter {
  final Uint8List _encryptionKey;

  _PointyCastleEncypter(this._encryptionKey);

  @override
  Uint8List decryptBinary(Uint8List encryptedData) {
    final Uint8List iv = Uint8List(16);
    final Uint8List encryptedPayload =
        Uint8List(encryptedData.length - iv.length);

    List.copyRange(iv, 0, encryptedData, 0, iv.length);
    List.copyRange(encryptedPayload, 0, encryptedData, iv.length);

    final PaddedBlockCipherParameters<CipherParameters?, CipherParameters?>
        params =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
      ParametersWithIV<KeyParameter>(KeyParameter(this._encryptionKey), iv),
      null,
    );

    final PaddedBlockCipherImpl decipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    )..init(false, params);

    final Uint8List originalData = decipher.process(encryptedPayload);

    return originalData;
  }

  @override
  Uint8List encryptBinary(Uint8List data) {
    final Uint8List iv =
        Uint8List.fromList(List<int>.generate(16, (_) => _random.nextInt(256)));

    final PaddedBlockCipherParameters<CipherParameters?, CipherParameters?>
        params =
        PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
      ParametersWithIV<KeyParameter>(KeyParameter(this._encryptionKey), iv),
      null,
    );

    final PaddedBlockCipherImpl cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    )..init(true, params);

    final Uint8List encryptedPayload = cipher.process(data);

    final Uint8List resultData =
        Uint8List(iv.length + encryptedPayload.length); // allocate space

    List.copyRange(resultData, 0, iv);
    List.copyRange(resultData, iv.length, encryptedPayload);

    return resultData;
  }

// 	public decryptBinary(encryptedData: Uint8Array): Buffer {
// 	}

// 	public decryptHex(encryptedHex: string): string {
// 		const encryptedData: Buffer = Buffer.from(encryptedHex, "hex");
// 		const decryptedData: Buffer = this.decryptBinary(encryptedData);
// 		return decryptedData.toString("utf8");
// 	}

// 	public encryptBinary(data: Uint8Array): Buffer {
// 	}

// 	public encryptHex(text: string): string {
// 		return this.encryptBinary(Buffer.from(text, "utf8")).toString("hex");
// 	}

}

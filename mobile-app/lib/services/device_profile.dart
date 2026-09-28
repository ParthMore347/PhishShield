import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceProfileProvider extends ChangeNotifier {
  DeviceProfileProvider._({
    required this.deviceId,
    required this.nickname,
    required this.avatarId,
    required SharedPreferences preferences,
  }) : _preferences = preferences;

  final SharedPreferences _preferences;
  final String deviceId;
  String nickname;
  String avatarId;

  static const avatarIds = ['shield', 'radar', 'fox', 'owl'];

  static Future<DeviceProfileProvider> load() async {
    final preferences = await SharedPreferences.getInstance();
    final deviceId = preferences.getString('device_id') ?? _newDeviceId();
    final profile = DeviceProfileProvider._(
      deviceId: deviceId,
      nickname: preferences.getString('device_nickname') ?? 'My Device',
      avatarId: preferences.getString('device_avatar_id') ?? 'shield',
      preferences: preferences,
    );
    if (preferences.getString('device_id') == null) {
      await preferences.setString('device_id', deviceId);
    }
    if (!avatarIds.contains(profile.avatarId)) {
      profile.avatarId = 'shield';
      await preferences.setString('device_avatar_id', profile.avatarId);
    }
    return profile;
  }

  Map<String, String> get scanMetadata => {
        'device_id': deviceId,
        'nickname': nickname,
        'avatar_id': avatarId,
      };

  Future<void> update(
      {required String nickname, required String avatarId}) async {
    final cleanNickname = nickname.trim();
    if (cleanNickname.isEmpty || cleanNickname.length > 40) {
      throw ArgumentError('Nickname must contain 1 to 40 characters.');
    }
    if (!avatarIds.contains(avatarId)) {
      throw ArgumentError('Choose a supported avatar.');
    }
    await _preferences.setString('device_nickname', cleanNickname);
    await _preferences.setString('device_avatar_id', avatarId);
    this.nickname = cleanNickname;
    this.avatarId = avatarId;
    notifyListeners();
  }

  static String _newDeviceId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return 'PS-${bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join()}';
  }
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_booth_state.g.dart';
part 'photo_booth_state.freezed.dart';

@freezed
class PhotoBoothState with _$PhotoBoothState {
  const factory PhotoBoothState.loading() = _Loading;
  const factory PhotoBoothState.error(String message) = _Error;
  const factory PhotoBoothState.data(PhotoBoothData data) = _Data;
}

@freezed
class PhotoBoothData with _$PhotoBoothData {
  const factory PhotoBoothData({
    @Default([]) List<String> photosPaths,
    @Default(false) bool isPhotoGridComplete,
    @Default(false) bool isCameraReady,
  }) = _PhotoBoothData;
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';

class MixingService {
  /// Mixes the instrumental URL and the recorded vocals file.
  /// [instrumentalUrl] URL of the backing track.
  /// [vocalsPath] Local path to the recorded `.m4a` file.
  /// [instrumentalVolume] 0.0 to 1.0.
  /// [vocalVolume] 0.0 to 1.0.
  /// [delaySeconds] Start time of the recording in seconds relative to the instrumental.
  /// Returns the path to the mixed output file.
  static Future<String?> mixAudio({
    required String instrumentalUrl,
    required String vocalsPath,
    required double instrumentalVolume,
    required double vocalVolume,
    required int delaySeconds,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final outputPath = '${dir.path}/mixed_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Ensure vocals path is properly formatted for FFmpeg
      final vocalsFile = File(vocalsPath);
      if (!await vocalsFile.exists()) {
        debugPrint('Vocals file does not exist: $vocalsPath');
        return null;
      }

      final delayMs = delaySeconds * 1000;
      
      // We use adelay with multiple channels just in case. 
      // amix=inputs=2:duration=first uses the duration of the first input (instrumental).
      // volume filters are applied to both.
      final command = "-y -i \"$instrumentalUrl\" -i \"$vocalsPath\" "
          "-filter_complex \"[0:a]volume=$instrumentalVolume[a1];[1:a]adelay=$delayMs|$delayMs,volume=$vocalVolume[a2];[a1][a2]amix=inputs=2:duration=first\" "
          "-c:a aac \"$outputPath\"";

      debugPrint('Executing FFmpeg: $command');
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint('Mix successful. Output: $outputPath');
        return outputPath;
      } else {
        final failStackTrace = await session.getFailStackTrace();
        debugPrint('Mix failed. Return code: $returnCode\nTrace: $failStackTrace');
        return null;
      }
    } catch (e) {
      debugPrint('Exception in MixingService: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class PistonExecutionResult {
  const PistonExecutionResult({
    required this.output,
    required this.isError,
    this.exitCode = 0,
  });

  final String output;
  final bool isError;
  final int exitCode;
}

/// Service to interact with Piston Code Execution API.
class PistonService {
  static Future<PistonExecutionResult> executeCode({
    required String language,
    required String code,
    String? stdin,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.pistonApiUrl}/execute');
      final normalizedLanguage = language.toLowerCase();

      // Piston version mappings
      String version = '*';
      if (normalizedLanguage == 'python' || normalizedLanguage == 'py') {
        version = '3.10.0';
      } else if (normalizedLanguage == 'javascript' ||
          normalizedLanguage == 'js') {
        version = '18.15.0';
      }

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'language': normalizedLanguage,
              'version': version,
              'files': [
                {'content': code}
              ],
              if (stdin != null && stdin.isNotEmpty) 'stdin': stdin,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return PistonExecutionResult(
          output: 'Execution API error (${response.statusCode}): ${response.body}',
          isError: true,
          exitCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final run = data['run'] as Map<String, dynamic>?;

      if (run == null) {
        return const PistonExecutionResult(
          output: 'No execution output returned.',
          isError: true,
        );
      }

      final stdout = (run['stdout'] as String?) ?? '';
      final stderr = (run['stderr'] as String?) ?? '';
      final exitCode = (run['code'] as num?)?.toInt() ?? 0;

      final output = (stdout + (stderr.isNotEmpty ? '\n$stderr' : '')).trim();

      return PistonExecutionResult(
        output: output.isEmpty ? '(Process finished with no output)' : output,
        isError: stderr.isNotEmpty || exitCode != 0,
        exitCode: exitCode,
      );
    } catch (e) {
      return PistonExecutionResult(
        output: 'Failed to connect to execution engine: $e',
        isError: true,
      );
    }
  }
}

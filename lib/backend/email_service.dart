import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed form submission service.
///
/// The app initializes Supabase in lib/main.dart using the same project
/// configuration as the Ardaita Unity and Development Association app.
class EmailService {
  static final SupabaseClient _client = Supabase.instance.client;


  static Future<void> sendContactEmail({
    required String fullName,
    required String email,
    required String message,
  }) async {

    await _client.from('contact_messages').insert({
      'full_name': fullName.trim(),
      'email': email.trim(),
      'message': message.trim(),
    });
  }

  static Future<void> sendVolunteerApplication({
    required String fullName,
    required String email,
    required String initiative,
    required String motivation,
  }) async {
    await _client.from('volunteer_applications').insert({
      'full_name': fullName.trim(),
      'email': email.trim(),
      'initiative': initiative.trim(),
      'motivation': motivation.trim(),









      });


  }
}

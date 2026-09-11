# Kecho backend integration
Kecho now uses the same Supabase integration as the current Ardaita Unity and Development Association Flutter app.
## Supabase project
- Project URL: `https://ukgrkpslqgggnuvfqzbb.supabase.co`
- Flutter package: `supabase_flutter: ^2.17.2`
The publishable key is configured in `lib/main.dart`, matching the Ardaita app. Do not replace it with a `service_role` key.
## Form endpoints
The Flutter forms write directly to Supabase:
- Contact form → `contact_messages`
  - `full_name`
  - `email`
  - `message`
- Volunteer form → `volunteer_applications`
  - `full_name`
  - `email`
  - `initiative`
  - `motivation`
Both submissions use `Supabase.instance.client` and surface Supabase errors through the existing form error handling.
## Required database/RLS setup
The Supabase project must contain these tables and allow anonymous/public `INSERT` through RLS, just as the Ardaita integration does. Example:
```sql
CREATE TABLE contact_messages (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL
);
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public inserts" ON contact_messages
  FOR INSERT WITH CHECK (true);
CREATE TABLE volunteer_applications (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  initiative TEXT NOT NULL,
  motivation TEXT NOT NULL
);
ALTER TABLE volunteer_applications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public inserts" ON volunteer_applications
  FOR INSERT WITH CHECK (true);
```
If these tables already exist, do not recreate them; verify the columns and RLS policies instead.
## Run
From the project directory:
```bash
flutter pub get
flutter run -d chrome
```
Then submit both forms and verify the rows appear in the Supabase Table Editor.
The old `mailto:` behavior has been removed from the form submissions: submitting a form now stores the data in Supabase rather than opening the visitor's email application.

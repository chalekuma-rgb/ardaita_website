# How to Fix the 401 Error - Get Your Supabase API Key

## The Problem
The error "401" means your API key is invalid or missing. The current key in the code ends with `.PLACEHOLDER` which is why it's failing.

## Solution: Get Your Real API Key

### Step 1: Open Supabase Dashboard
Go to: https://supabase.com/dashboard/project/ukgrkpslqgggnuvfqzbb

### Step 2: Navigate to API Settings
1. Click the **Settings** icon (gear icon ⚙️) in the left sidebar
2. From the left menu, click **API**

### Step 3: Copy Your Anon Public Key
You'll see a section called "Project API keys"

Look for the key that starts with: **eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...**

Click the **copy** icon next to "anon public" to copy the entire key

It should be a long string (150-300+ characters) that looks like:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1a2tobGJnbWNuaHN0ZGZtZWVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwMDAwMDAsImV4cCI6MTc2MDAwMDAwMH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Step 4: Update the Code
1. Open: `lib/main.dart`
2. Find line 7-8:
```dart
  static const String _supabaseApiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1a2tobGJnbWNuaHN0ZGZtZWVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwMDAwMDAsImV4cCI6MTc2MDAwMDAwMH0.PLACEHOLDER';
```

3. Replace the entire string (between the single quotes) with your copied API key

### Step 5: Verify
The final result should look like:
```dart
  static const String _supabaseApiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1a2tobGJnbWNuaHN0ZGZtZWVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwMDAwMDAsImV4cCI6MTc2MDAwMDAwMH0.XXXXxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
```
(No `.PLACEHOLDER` at the end!)

### Step 6: Test Again
1. Save the file
2. Refresh your Flutter web app
3. Try submitting the contact form again

## Still Getting 401?

If you still get 401 after adding the correct API key, check:

1. **Database Tables Exist**: Did you run the SQL scripts from SUPABASE_SETUP.md to create the tables?
   - Table names must be: `contact_messages` and `volunteer_applications`
   - Must be lowercase with underscores

2. **Row Level Security (RLS)**: 
   - Go to Supabase → Tables
   - For each table, check that RLS policies allow public inserts
   - Run this SQL if needed:
   ```sql
   ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
   CREATE POLICY "Allow public inserts" ON contact_messages
     FOR INSERT WITH CHECK (true);
   ```

3. **Check Browser Console**:
   - Press F12 in your browser
   - Go to Console tab
   - Look for error messages with more details

## Need Help?

- Supabase API Keys: https://supabase.com/docs/guides/api/api-keys
- Supabase REST API: https://supabase.com/docs/guides/api
- Check the SUPABASE_CONFIG.md file for more info

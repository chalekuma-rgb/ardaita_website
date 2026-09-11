# How to Get Your Supabase API Key - Step by Step

## The Problem
Your API key is currently empty (`''`), which is why you're getting a 401 error.

## Solution - Get Your Real API Key

### Step 1: Open Supabase Dashboard
Click this link: **https://supabase.com/dashboard/project/ukgrkpslqgggnuvfqzbb**

Or manually:
- Go to https://supabase.com
- Log in with your account
- Find your project "ukgrkpslqgggnuvfqzbb"
- Click to open it

### Step 2: Navigate to API Settings
In the left sidebar, look for **Settings** (⚙️ gear icon)

Click on it.

### Step 3: Click on "API"
From the settings menu on the left, click **API**

### Step 4: Find Your Anon Public Key
You should see a section titled **"Project API keys"**

Look for two keys:
- `service_role` (🔴 red/private - DO NOT USE!)
- `anon public` (🟢 green/public - THIS IS THE ONE!)

### Step 5: Copy the Anon Public Key
Click the **copy icon** (📋) next to the "anon public" key

The key should be a long string that looks like:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV1a2tobGJnbWNuaHN0ZGZtZWVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwMDAwMDAsImV4cCI6MTc2MDAwMDAwMH0.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

It's typically 200-300+ characters long.

### Step 6: Update the Dart Code
1. Open the file: `lib/main.dart`

2. Find this line (around line 9):
```dart
  static const String _supabaseApiKey = '';  // ← PASTE YOUR KEY HERE
```

3. Paste your API key between the quotes:
```dart
  static const String _supabaseApiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; 
```

4. Make sure there are NO spaces at the beginning or end

5. Save the file (Ctrl+S)

### Step 7: Test Again
1. Refresh your Flutter web app (F5)
2. Try submitting the contact form again
3. You should no longer get a 401 error!

## Troubleshooting

### Still Getting 401?
1. **Check the key is complete**: Make sure the entire long string is pasted (no truncation)
2. **No extra spaces**: There should be no spaces before or after the key
3. **Used anon public key?**: Make sure you copied the green "anon public" key, NOT the red "service_role" key

### Check Database Tables Exist
If you get past 401 but form still fails:
1. Go to Supabase → **Database** → **Tables** 
2. Verify these tables exist:
   - `contact_messages`
   - `volunteer_applications`

If they don't exist, run the SQL from `SUPABASE_SETUP.md`

## Still Having Issues?

Check your browser console for more details:
1. Press **F12** to open Developer Tools
2. Click the **Console** tab
3. Look for error messages
4. Copy any errors and check them against the troubleshooting guide

---

**Need the actual key from your Supabase project?**
If you need help finding it:
1. Your project reference is: `ukgrkpslqgggnuvfqzbb`
2. The key should be in: Settings → API → Project API Keys
3. Copy the "anon public" key (the green one)

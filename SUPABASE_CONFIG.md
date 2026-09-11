# Supabase Backend Configuration

This document explains how to configure the Supabase backend for the Ardaita website.

## Quick Start

### 1. Get Your Supabase API Key

1. Go to: https://supabase.com/dashboard/project/ukgrkpslqgggnuvfqzbb
2. Click **Settings** (gear icon) in the left sidebar
3. Click **API** in the left menu
4. Copy the **anon public** key from the "Project API keys" section
5. It should look something like: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 2. Update the Email Service

In `lib/main.dart`, replace the placeholder:

```dart
static const String _supabaseApiKey = 'your-actual-api-key-here';
```

### 3. Set Up Database Tables

Go to https://supabase.com/dashboard/project/ukgrkpslqgggnuvfqzbb/sql/new

Paste and run both SQL scripts from `SUPABASE_SETUP.md`:
- Contact Submissions Table
- Volunteer Applications Table

### 4. Test the Setup

1. Run the Flutter app: `flutter run -d chrome`
2. Fill out and submit a contact form
3. Check the Supabase dashboard → **Table Editor** → **contact_messages** to see your submission

## How It Works

1. **User submits form** → Flutter app sends data to Supabase REST API
2. **Data stored** → Submission appears in database table
3. **Notifications** (optional) → Set up webhooks or email functions to notify info@ardaita-asca.org

## Database Tables

### contact_messages
- `id` - Auto-generated primary key
- `created_at` - Timestamp of submission
- `full_name` - User's full name
- `email` - User's email address
- `message` - Contact message

### volunteer_applications
- `id` - Auto-generated primary key
- `created_at` - Timestamp of submission
- `full_name` - Applicant's full name
- `email` - Applicant's email address
- `initiative` - Selected initiative
- `motivation` - Motivation text

## Adding Email Functionality

To actually send emails, follow these steps:

1. **Option A: Use Resend**
   - Sign up at https://resend.com
   - Create API key
   - Follow the "Add Email Sending with Resend" section in SUPABASE_SETUP.md

2. **Option B: Use Supabase Functions**
   - Install Supabase CLI: `npm install -g supabase`
   - Create Edge Functions to send emails
   - See SUPABASE_SETUP.md for detailed instructions

3. **Option C: Use Database Webhooks**
   - Set up webhooks to notify an external service
   - The external service can then send emails

## Security Notes

- The `anon public` key is safe to use in the Flutter app
- Row Level Security (RLS) policies ensure only inserts are allowed from public users
- No modifications or deletions are allowed without authentication

## Troubleshooting

**Problem**: "401 Unauthorized"
- **Solution**: Check that your API key is correct

**Problem**: "404 Not Found"
- **Solution**: Ensure tables exist and are named correctly (lowercase with underscores)

**Problem**: Form submission fails silently
- **Solution**: Check browser console (F12) for CORS errors

**Problem**: Data not appearing in database
- **Solution**: Check RLS policies allow inserts, or disable them temporarily for testing

## More Information

- Supabase Docs: https://supabase.com/docs
- REST API Guide: https://supabase.com/docs/guides/api
- Edge Functions: https://supabase.com/docs/guides/functions
- See `SUPABASE_SETUP.md` for complete setup guide

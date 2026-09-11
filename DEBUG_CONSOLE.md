# Debugging the 401 Error - Check Browser Console

## How to See Detailed Error Messages

The app now logs detailed information to the browser console to help debug issues.

### Step 1: Open Developer Tools

Press **F12** on your keyboard while the Flutter app is running.

(Or right-click → Inspect)

### Step 2: Go to Console Tab

Click on the **Console** tab at the top of the developer tools.

### Step 3: Try Submitting the Form

Fill out the contact form and click Submit.

### Step 4: Look for [EmailService] Messages

You should see messages like:

```
[EmailService] Sending to: https://ukgrkpslqgggnuvfqzbb.supabase.co/rest/v1/contact_messages
[EmailService] Table: contact_messages
[EmailService] Payload: {fullName: "John Doe", email: "john@example.com", message: "Hello"}
[EmailService] ✗ Error: Authentication failed (401). Your API key may be invalid...
```

## Understanding the Messages

### ✓ Success Message
```
[EmailService] ✓ Submission sent successfully to contact_messages
```
Everything worked! Check Supabase dashboard to see your data.

### ✗ API Key Not Set
```
[EmailService] ✗ Exception: Supabase API key is not configured...
```
**Solution**: Add your API key to `lib/main.dart`
See `GET_SUPABASE_API_KEY.md`

### ✗ 401 - Authentication Failed
```
[EmailService] ✗ Error: Authentication failed (401). Your API key may be invalid...
```
**Solution**: 
1. Check that your API key is complete (no truncation)
2. Make sure there are no spaces at the beginning/end
3. Verify you copied the "anon public" key (not "service_role")

### ✗ 404 - Table Not Found
```
[EmailService] ✗ Error: Table not found (404). Check that contact_messages table exists...
```
**Solution**: 
1. Open Supabase dashboard
2. Go to Database → Tables
3. Verify the table exists: `contact_messages` or `volunteer_applications`
4. If missing, run the SQL from `SUPABASE_SETUP.md`

### ✗ 400 - Bad Request
```
[EmailService] ✗ Error: Bad request (400). Response: {...}. Check field names...
```
**Solution**:
1. The payload field names don't match the database columns
2. Check that your table has columns: `full_name`, `email`, `message` (with underscores)
3. Or the data types don't match

### ✗ Network Error
```
[EmailService] ✗ Network error: Failed to send submission...
```
**Solution**:
1. Check your internet connection
2. Make sure Supabase project is active
3. Check if CORS is properly configured

## Common 401 Solutions Checklist

- [ ] API key is added to `email_service.dart` (not empty)
- [ ] API key is complete and wasn't truncated
- [ ] No spaces before or after the key
- [ ] Used "anon public" key, not "service_role" key
- [ ] Database tables exist (`contact_messages`, `volunteer_applications`)
- [ ] Row Level Security (RLS) policies allow public inserts
- [ ] Supabase project is active (not paused)

## How to Copy the Full API Key

Sometimes people accidentally copy only part of the key. Here's how to verify:

1. Open Supabase Dashboard: https://supabase.com/dashboard/project/ukgrkpslqgggnuvfqzbb
2. Settings → API
3. Right-click the copy button next to "anon public"
4. Select "Inspect" to see the full key before copying
5. Or manually select and copy the entire key yourself

The key should:
- Start with: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`
- Be 200+ characters long
- Contain periods (.) separating JWT parts
- End with a random string of alphanumeric characters

## Still Stuck?

1. Copy the full error message from the console
2. Check against the solutions above
3. Verify all steps in `GET_SUPABASE_API_KEY.md`
4. Make sure database tables are created (see `SUPABASE_SETUP.md`)

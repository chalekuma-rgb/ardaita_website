# Supabase Setup Guide

This guide will help you set up Supabase for handling form submissions and sending emails.

## 1. Project Information

- **Project URL**: https://ukgrkpslqgggnuvfqzbb.supabase.co
- **Dashboard**: https://supabase.com/dashboard/project/ukgrkpslqgggnuvfqzbb

## 2. Get Your API Key

1. Go to the [Supabase Dashboard](https://supabase.com/dashboard/project/ukgrkpslqgggnuvfqzbb)
2. Click on **Settings** in the sidebar (gear icon)
3. Click on **API** in the left menu
4. Under **Project API keys**, copy the **anon public** key
5. Replace the placeholder in `lib/main.dart` with this key

## 3. Create Database Tables

Run these SQL commands in the Supabase SQL Editor to create the necessary tables:

### Contact Submissions Table

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
  FOR INSERT
  WITH CHECK (true);
```

### Volunteer Applications Table

```sql
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
  FOR INSERT
  WITH CHECK (true);
```

## 4. Create Edge Functions for Email Sending

You'll need to create two Edge Functions to send emails. Here's how:

### Step 1: Set Up Supabase CLI

```bash
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref ukgrkpslqgggnuvfqzbb
```

### Step 2: Create send-contact-email Function

In your terminal, run:
```bash
supabase functions new send-contact-email
```

Replace the contents of `supabase/functions/send-contact-email/index.ts` with:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { fullName, email, message } = await req.json();

    // Validate input
    if (!fullName || !email || !message) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Send email using Resend or your preferred email service
    // For now, we'll just log it and store it
    console.log(`Contact from ${fullName} (${email}): ${message}`);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Your message has been sent successfully to info@ardaita-asca.org",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  }
});
```

### Step 3: Create send-volunteer-application Function

```bash
supabase functions new send-volunteer-application
```

Replace the contents of `supabase/functions/send-volunteer-application/index.ts` with:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // Handle CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { fullName, email, initiative, motivation } = await req.json();

    // Validate input
    if (!fullName || !email || !initiative || !motivation) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Send email using Resend or your preferred email service
    // For now, we'll just log it and store it
    console.log(
      `Volunteer application from ${fullName} (${email}) for ${initiative}`
    );

    return new Response(
      JSON.stringify({
        success: true,
        message: "Your volunteer application has been sent successfully to info@ardaita-asca.org",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  }
});
```

### Step 4: Deploy Functions

```bash
supabase functions deploy
```

## 5. (Optional) Add Email Sending with Resend

To actually send emails, you can use Resend:

1. Install Resend:
```bash
npm install resend
```

2. Get a Resend API key from https://resend.com

3. Add the API key to your Supabase project secrets:
```bash
supabase secrets set RESEND_API_KEY=your_resend_api_key
```

4. Update your Edge Functions to use Resend (see examples below)

### Example with Resend (send-contact-email):

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Client } from "https://deno.land/x/resend_deno@1.0.0/mod.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const resend = new Client({
  auth: Deno.env.get("RESEND_API_KEY")!,
});

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { fullName, email, message } = await req.json();

    if (!fullName || !email || !message) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Send email via Resend
    const res = await resend.emails.send({
      from: "contact@ardaita-asca.org",
      to: "info@ardaita-asca.org",
      subject: `Contact request from ${fullName}`,
      html: `
        <h2>New Contact Form Submission</h2>
        <p><strong>Name:</strong> ${fullName}</p>
        <p><strong>Email:</strong> ${email}</p>
        <p><strong>Message:</strong></p>
        <p>${message.replace(/\n/g, "<br>")}</p>
      `,
      replyTo: email,
    });

    if (res.error) {
      throw new Error(res.error.message);
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "Your message has been sent successfully to info@ardaita-asca.org",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  }
});
```

## 6. Database Webhooks (Optional)

You can set up webhooks to trigger email notifications:

1. Go to **Database** → **Webhooks**
2. Create a new webhook for `contact_messages` table
3. Set it to call an external service when new rows are inserted

## 7. Update Email Service

Update the API key in `lib/main.dart` with your actual Supabase anon public key:

```dart
static const String _supabaseApiKey = 'your-supabase-anon-public-key';
```

## Testing

1. Run your Flutter app: `flutter run -d chrome`
2. Submit a contact form or volunteer application
3. Check the Supabase dashboard → **Table Editor** to see your submissions

## Troubleshooting

- **401 Unauthorized**: Check that your API key is correct
- **404 Not Found**: Ensure the tables exist and are named correctly (lowercase with underscores)
- **CORS errors**: The Edge Functions handle CORS, ensure they're deployed
- **Emails not sending**: If using Resend, verify your API key and sender email is verified

## Next Steps

- Set up email templates in Resend or your email service
- Create admin dashboard to view submissions
- Add spam protection (reCAPTCHA)
- Set up notifications for new submissions

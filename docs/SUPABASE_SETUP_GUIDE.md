# Supabase Setup Guide

**Time**: 12 min | **For**: Backend (Database + Auth + Storage)

## 1. Create Project

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Fill in:
   - **Name**: Your app name
   - **Region**: Closest to your users
   - **Password**: Save it (for database access)
3. Wait ~2 minutes for project creation

### Get API Keys

Go to **Project Settings** → **API**:

**📋 Save these**:
- **Project URL**: `https://yourproject.supabase.co`
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsIn...`

---

## 2. Authentication Setup

### Apple Sign-In

1. **Supabase**: Dashboard → **Authentication** → **Providers** → **Apple**
2. Toggle **Enable**
3. Under **Authorized Client IDs**, paste your **Bundle ID** (from Xcode)
4. Click **Save**

### Google Sign-In

Already configured via [Google OAuth Guide](./setup/GOOGLE_OAUTH.md).

---

## 3. Database Setup

Go to **SQL Editor** and run these scripts:

### Create Profiles Table

```sql
create table public.profiles (
  id uuid not null references auth.users on delete cascade,
  email text,
  full_name text,
  avatar_url text,
  updated_at timestamp with time zone,
  primary key (id)
);
```

### Enable Row Level Security

```sql
alter table public.profiles enable row level security;

-- Public profiles viewable by everyone
create policy "Public profiles viewable"
  on profiles for select using (true);

-- Users can insert own profile
create policy "Users insert own profile"
  on profiles for insert with check (auth.uid() = id);

-- Users can update own profile
create policy "Users update own profile"
  on profiles for update using (auth.uid() = id);
```

### Auto-Create Profile on Sign Up

```sql
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'email',
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

---

## 4. Storage Setup

### Create Storage Bucket

1. Go to **Storage** → **New bucket**
2. Name: `storage`
3. Toggle **Public bucket** ON
4. Click **Create bucket**

### Set Storage Policies

Go to **Policies** tab on the bucket:

```sql
-- Anyone can view files
create policy "Public Access"
  on storage.objects for select
  using (bucket_id = 'storage');

-- Authenticated users can upload
create policy "Authenticated users upload"
  on storage.objects for insert
  with check (bucket_id = 'storage' AND auth.role() = 'authenticated');

-- Users can update own files
create policy "Users update own files"
  on storage.objects for update
  using (auth.uid()::text = (storage.foldername(name))[1]);

-- Users can delete own files
create policy "Users delete own files"
  on storage.objects for delete
  using (auth.uid()::text = (storage.foldername(name))[1]);
```

---

## 5. Edge Functions (Optional)

For admin operations like account deletion.

### Create Delete Account Function

1. In your project, create: `supabase/functions/delete-account/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const authHeader = req.headers.get('Authorization')!
  const token = authHeader.replace('Bearer ', '')
  const { data: { user } } = await supabaseClient.auth.getUser(token)

  if (!user) {
    return new Response('Unauthorized', { status: 401 })
  }

  // Delete user
  await supabaseClient.auth.admin.deleteUser(user.id)

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### Deploy Function

```bash
npx supabase functions deploy delete-account
```

---

## ✅ Checklist

- [ ] Supabase project created
- [ ] API URL and anon key saved
- [ ] Apple Sign-In enabled
- [ ] Google Sign-In configured
- [ ] Profiles table created
- [ ] RLS policies enabled
- [ ] Storage bucket created (`storage`)
- [ ] Storage policies set
- [ ] Edge function deployed (optional)

**Saved Values**:
```
Supabase URL: https://yourproject.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIs...
```

## Next Step

→ [Configure App Keys](./setup/APP_CONFIGURATION.md)

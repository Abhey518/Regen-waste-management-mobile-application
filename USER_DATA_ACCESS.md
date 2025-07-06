# User Data Access Pattern

This document explains how user data is accessed and displayed in the profile window.

## Database Structure

The app uses a two-tier user system:

### 1. **Supabase Auth Users** (`auth.users`)
- Handles authentication (login/logout)
- Stores basic auth data like email
- Accessed via: `Supabase.instance.client.auth.currentUser`

### 2. **User Profiles Table** (`users`)
- Stores detailed user profile information
- Linked to auth users via the same UUID
- Accessed via: `_supabase.from('users')`

## User Profile Table Structure

Based on the registration process, the `users` table contains:

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,  -- Same as auth.users.id
    email VARCHAR,
    first_name VARCHAR,
    last_name VARCHAR,
    phone VARCHAR,
    nic_or_passport VARCHAR,
    address TEXT,
    province_id INTEGER,
    district_id INTEGER,
    local_authority_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

## Updated Implementation

### UserService (`lib/services/user_service.dart`)

The `UserService` provides clean methods to:

1. **`getUserProfile()`** - Fetch user profile from the `users` table
2. **`formatUserName()`** - Extract and format user's full name
3. **`formatUserEmail()`** - Get user's email with fallbacks
4. **`updateUserProfile()`** - Update user profile data
5. **`hasUserProfile()`** - Check if user has a profile record

### ProfileWindow Implementation

The profile window now:

1. **Loads from Database**: Uses `UserService.getUserProfile()` to fetch actual user data
2. **Shows Real Names**: Displays `first_name + last_name` from the database
3. **Handles Errors**: Falls back gracefully if profile doesn't exist
4. **Supports Refresh**: Pull-to-refresh updates data from database

## Name Display Logic

The `formatUserName()` method follows this priority:

1. **Full Name**: `first_name + last_name` (e.g., "John Doe")
2. **First Name Only**: If last name is empty (e.g., "John")
3. **Last Name Only**: If first name is empty (e.g., "Doe")
4. **Fallback**: "User" if both are empty

## Email Display Logic

The `formatUserEmail()` method:

1. **Profile Email**: From `users.email` field
2. **Auth Email**: From `auth.users.email` 
3. **Fallback**: "No email" if neither exists

## Error Handling

- **Profile Not Found**: Falls back to auth user email username
- **Network Errors**: Shows cached data or graceful error states
- **Auth Errors**: Shows "Guest User" state

## Usage Example

```dart
// Load user profile
final profile = await UserService.getUserProfile();

// Format name
final name = UserService.formatUserName(profile);
// Result: "John Doe" or "John" or "User"

// Format email
final email = UserService.formatUserEmail(profile);
// Result: "john.doe@example.com" or "No email"
```

## Benefits

✅ **Real User Data**: Shows actual names from registration  
✅ **Database-Driven**: Always up-to-date with profile changes  
✅ **Robust Fallbacks**: Graceful handling of missing data  
✅ **Maintainable**: Clean separation of concerns  
✅ **Extensible**: Easy to add more profile fields  

This implementation ensures users see their actual names (like "John Doe") instead of email-based usernames, providing a much more personalized experience.

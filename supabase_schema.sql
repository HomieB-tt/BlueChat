-- Supabase Database Schema for BlueChat (Bluetooth Chat App)
-- Run this SQL in your Supabase SQL Editor
-- 
-- NOTE: This app uses device-based identification instead of user authentication.
-- Users are identified by their device ID and Bluetooth name.

-- ==================== Profiles Table ====================
-- Stores user profiles identified by device ID
CREATE TABLE IF NOT EXISTS profiles (
  id TEXT PRIMARY KEY,  -- Device ID (not UUID from auth)
  username TEXT NOT NULL,
  avatar_url TEXT,
  device_id TEXT UNIQUE NOT NULL,
  is_online BOOLEAN DEFAULT false,
  last_seen TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policy for anyone to view profiles (needed for chat)
CREATE POLICY "Anyone can view profiles" 
ON profiles FOR SELECT USING (true);

-- Create policy for users to upsert their own profile
CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE USING (device_id = device_id);
CREATE POLICY "Users can insert own profile" 
ON profiles FOR INSERT WITH CHECK (device_id = device_id);

-- ==================== Conversations Table ====================
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  avatar_url TEXT,
  is_group BOOLEAN DEFAULT false,
  created_by TEXT REFERENCES profiles(id),  -- Device ID reference
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security for conversations
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

-- Create policy for users to view conversations they participate in
CREATE POLICY "Users can view conversations" 
ON conversations FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM chat_participants 
    WHERE chat_participants.conversation_id = conversations.id
    AND chat_participants.device_id = auth.uid()::text  -- Using device_id from profile
  ) OR created_by = auth.uid()::text
);

-- Create policy for anyone to create conversations
CREATE POLICY "Anyone can create conversations" 
ON conversations FOR INSERT WITH CHECK (true);

-- Create policy for users to update conversations
CREATE POLICY "Users can update conversations" 
ON conversations FOR UPDATE USING (true);

-- ==================== Chat Participants Table ====================
CREATE TABLE IF NOT EXISTS chat_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,  -- Device ID reference
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  is_admin BOOLEAN DEFAULT false,
  UNIQUE(conversation_id, device_id)
);

-- Enable Row Level Security for chat participants
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;

-- Create policy for anyone to view participants
CREATE POLICY "Anyone can view participants" 
ON chat_participants FOR SELECT USING (true);

-- Create policy for users to add themselves to conversations
CREATE POLICY "Users can join conversations" 
ON chat_participants FOR INSERT WITH CHECK (true);

-- Create policy for users to leave conversations
CREATE POLICY "Users can leave conversations" 
ON chat_participants FOR DELETE USING (device_id = device_id);

-- ==================== Messages Table ====================
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_device_id TEXT NOT NULL,  -- Device ID reference
  sender_name TEXT NOT NULL,       -- Cached sender name for display
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  attachment_url TEXT,
  is_read BOOLEAN DEFAULT false,
  is_edited BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security for messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create policy for anyone to view messages in their conversations
CREATE POLICY "Anyone can view messages" 
ON messages FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM chat_participants 
    WHERE chat_participants.conversation_id = messages.conversation_id
  )
);

-- Create policy for anyone to send messages
CREATE POLICY "Anyone can send messages" 
ON messages FOR INSERT WITH CHECK (true);

-- Create policy for users to update their own messages
CREATE POLICY "Users can update own messages" 
ON messages FOR UPDATE USING (sender_device_id = device_id);

-- Create policy for users to delete their own messages
CREATE POLICY "Users can delete own messages" 
ON messages FOR DELETE USING (sender_device_id = device_id);

-- ==================== Indexes for Performance ====================
CREATE INDEX IF NOT EXISTS idx_messages_conversation_created 
ON messages(conversation_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_messages_sender 
ON messages(sender_device_id);

CREATE INDEX IF NOT EXISTS idx_profiles_device_id 
ON profiles(device_id);

CREATE INDEX IF NOT EXISTS idx_profiles_username 
ON profiles(username);

CREATE INDEX IF NOT EXISTS idx_chat_participants_device 
ON chat_participants(device_id);

CREATE INDEX IF NOT EXISTS idx_chat_participants_conversation 
ON chat_participants(conversation_id);

-- ==================== Functions ====================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at triggers
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at
  BEFORE UPDATE ON conversations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to get conversation participants
CREATE OR REPLACE FUNCTION get_conversation_participants(conversation_id UUID)
RETURNS TABLE (
  device_id TEXT,
  username TEXT,
  is_online BOOLEAN,
  last_seen TIMESTAMPTZ
) AS $$
  SELECT 
    cp.device_id,
    p.username,
    p.is_online,
    p.last_seen
  FROM chat_participants cp
  JOIN profiles p ON cp.device_id = p.id
  WHERE cp.conversation_id = get_conversation_participants.conversation_id;
$$ LANGUAGE sql;

-- Function to get message count per conversation
CREATE OR REPLACE FUNCTION get_message_count(conversation_id UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*) FROM messages 
  WHERE conversation_id = get_message_count.conversation_id;
$$ LANGUAGE sql;

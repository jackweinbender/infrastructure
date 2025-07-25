-- Create pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;
-- Create a sample database for testing
CREATE DATABASE app_db;
-- Connect to the new database and enable vector extension there too
\ c app_db;
CREATE EXTENSION IF NOT EXISTS vector;
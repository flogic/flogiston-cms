# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_flogiston_session',
  :secret      => '7f57c62cbd53f22c68ac57eca086c6a9f4536d38b6d7953ec1a31d57ceccf595b87b30c04e9398de17d1e65e469dc9b59fa4cd95f3cdd699dca172276a724310'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

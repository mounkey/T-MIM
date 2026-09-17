# Jules Setup Instructions

This repository is configured for a Ruby on Rails application (version 8.2.0.alpha) with PostgreSQL 16.

To fully set up the environment, including database and server, follow these steps in order.

## 1. System Dependencies

This project requires a specific set of system libraries. Run this command to install them:

```bash
sudo apt-get update
sudo apt-get install -y ruby-full libpq-dev libvips postgresql postgresql-client nodejs npm build-essential git libyaml-dev pkg-config chromium-browser
```

## 2. PostgreSQL Setup

The database server needs to be started and a user created for the application.

```bash
# Start PostgreSQL service
sudo service postgresql start

# Create the 'jules' user with superuser privileges (password 'password')
sudo -u postgres psql -c "CREATE USER jules WITH SUPERUSER PASSWORD 'password';"
```

## 3. Ruby & Gem Installation

The project uses Bundler to manage Ruby dependencies. We install them locally to avoid permission issues.

```bash
# Configure Bundler to install gems in vendor/bundle
bundle config set --local path 'vendor/bundle'

# Install Ruby gems
bundle install
```

## 4. Node Modules (Frontend)

Install JavaScript dependencies.

```bash
npm install
```

## 5. Database Initialization

Prepare the database (create and migrate). We export environment variables to match the user we created.

```bash
export POSTGRES_USER=jules POSTGRES_PASSWORD=password POSTGRES_HOST=localhost
bin/rails db:prepare
```

## 6. Running the Server

Start the Rails server.

```bash
export POSTGRES_USER=jules POSTGRES_PASSWORD=password POSTGRES_HOST=localhost
bin/rails server
```

The application will be available at `http://localhost:3000`.

## Notes for Agents

*   **Bundler Path**: Always use `vendor/bundle` for gems.
*   **Database User**: The `jules` user is configured with password `password`. Ensure `POSTGRES_HOST=localhost` is set, otherwise Rails might try to connect via socket in a way that fails in this sandbox.
*   **Git Ignored**: `vendor/` and `node_modules/` are added to `.gitignore`.

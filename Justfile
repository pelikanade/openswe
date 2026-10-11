# Open SWE dashboard: http://127.0.0.1:2024/
# PostgreSQL persists in .devenv/state/postgres; agent state in .langgraph_api.
# Export provider credentials before starting; GitHub login uses `gh auth login`.

# List the available commands.
default:
    @just --list

# Start PostgreSQL and Open SWE; Ctrl-C stops both. Data persists.
run:
    devenv up

# Start both services in the background.
up:
    devenv up --detach

# Stop background services without deleting their data.
down:
    devenv processes down

# Show service status.
status:
    devenv processes list

# Open the project database with the configured Unix socket.
db:
    devenv shell -- psql

# Enter the development environment.
shell:
    devenv shell

# goodtool (or tooldb)

Tool tracking(electrical crimpers) application based on [racket/koyo](https://docs.racket-lang.org/koyo/index.html) framework. Styled after Monokai theme colors.

![Screnshot](goodtool.JPG)

## Setup

### Requirements

* You need [Racket] since this is a Racket application.
* You need [Node.js] version 20 or higher to build the assets.
* You need access to a couple local [Postgres] databases. One named
  `tooldb` and the other `tooldb_tests`. The latter is
  exercised by unit tests.

### First-time Setup

    npm install && npm run build
    raco pkg install chief
    raco pkg install tooldb/        # install and build the application and its deps
    raco pkg install tooldb-tests/  # install and build the tests and their deps

### Development environment

Copy `.env.default` to `.env`. [chief] will automatically load the
variables defined in this file into the environment of the subprocesses
defined in the `Procfile` whenever it is run.

The app expects to be run behind an SSL terminated connection (for
example, behind an nginx instance using a self-signed cert), even for
local development. You can disable this requirement by setting the
`TOOLDB_DEBUG` environment variable to `x`.

## Running the app locally

    raco chief start

## Running the console

    racket tooldb/dynamic.rkt console


[Postgres]: https://www.postgresql.org/
[Racket]: https://racket-lang.org/
[Node.js]: https://nodejs.org/en/
[argon2]: https://www.argon2.com/
[chief]: https://github.com/Bogdanp/racket-chief

## Database
This application requires running Postgres database server on `127.0.0.1` on port `5432`, with database `tooldb`, accessible by user `tooldb` with password `tooldb`. Or in other words you should be able to connect to it using following URL:
`postgres://tooldb:tooldb@127.0.0.1:5432/tooldb`
`
sudo -u postgres psql
ALTER SYSTEM SET password_encryption = 'md5';
SELECT pg_reload_conf();
CREATE USER tooldb WITH PASSWORD 'tooldb';
CREATE DATABASE tooldb OWNER tooldb;
GRANT ALL PRIVILEGES ON DATABASE tooldb TO tooldb;
\q`


`sudo nano /etc/postgresql/*/main/pg_hba.conf`
Change from scram-sha-256 or whatever latest thing in fashion to something that actually works:
`host    all             all             127.0.0.1/32            md5`

sudo systemctl restart postgresql

## Docker
- `docker_build.sh` - Use this to build docker container named `goodtool`
- `docker_run.sh` - Use this to lauch docker container after it's built, this will also start the server inside the container.


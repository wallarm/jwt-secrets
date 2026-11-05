<div align="center">

# jCracka

jCracka is a tool written in Bash that automates the process of attempting to crack and resign HS256 Json web-tokens for testing authentication systems in things like WebApps.

`github.com/OSINTI4L`

</div>

## Usage
### Cracking JWT
Invoke jCracka.sh via `./jCracka.sh` to attempt to crack a user supplied HS256 Json web-token with `hashcat` and a compiled list of known JWT secrets supplied by [wallarm](https://github.com/wallarm/jwt-secrets/).

### Resigning
Once a JWT secret is known, a user may invoke `./jCracka.sh -r` OR `./jCracka.sh --resign` to resign the JWT with a user supplied Json payload.

jCracka is fully automated and will prompt the user for the required information,

simple as.

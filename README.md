# CarmineGql

## TODO:
  - [x] 1) inside our producer currently, we're loading all the users when the demand is actually known for how many users are needed, instead we need to filter through these using limit & offset while storing the current position in the genstage, this way we can go through all the users till the end and restart
  - [ ] 2) Currently we're also doing the same for our ets tokens, getting all the tokens will become very expensive  so instead we'll want to map through the returned users and use get on them (which is still much faster than getting all tokens as the ets table grows)

### Notes
- TODO: Code refactoring
- Should we also write tests for the auth tokens cache?



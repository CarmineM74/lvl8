# CarmineGql

## GenStage Pipeline

Now that we have all our emails in place, we're going to write a system to run through all the users daily and generate an auth token unique to that user,
it will store it within some sort of cache, for us to then be able to give this auth token to the user.
For the purpose of this assignment, no external libraries are allowed.
To do this we're going to create a GenStage system that will allow us to Produce users and our consumers can generate tokens for that user or remove stale ones if necessary

### Solution
GenStage will perform token generation, while storage can be cached using ETS and NonBlockingGenServer, the same way we did with GqlRequestStats

Producer will populate Tokens cache daily with unique auth token per user.

### Notes
- What should happen if the an attempt to fetch the token is performed while the cache is being purged?

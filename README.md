# CarmineGql

## GQL Modifications
Now that we have our auth tokens being generated, we need a way to get a token for a current user using GraphQL.
What we're going to do, is add an `auth_token` field to our user type, and have that return the auth_token from our cache, for the user.
We're also going to add a subscription for `userAuthToken(user_id: String!): string` which will trigger whenever a new token is generated
for a specific user_id.

### Notes
- Tests must be written for the GQL part
- Should we also write tests for the auth tokens cache?

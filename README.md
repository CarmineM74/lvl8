# CarmineGql

## TODO:
  - [x] Web API Speedup
  - [x] Distributed Request Counter
        On top of this, we're going to change the request counter to work in a distributed environment, using one of the caching strategies we've talked about in the past week. 
        Figure out the different tradeoffs and leave a comment on why you chose the specific cache style in a module doc of the request counter. 
        For this cache part Redis and off-server caching isn't allowed.
  - [x] Caching Telemetry
        Make sure we use our prometheus skills to add in telemetry for whatever caching form we choose. 
        Potentially measuring times for get/put as well as count.
  - [ ] Testing: Make sure we have testing for our new caching systems

  - **Optional**: For extra credit you can try implementing a Singleton Cache that would be accessed in a distributed environment (meaning one node has the data and the rest pull it from that node, think about how you select which node holds the data), use this for the Distributed Request Counter

### Notes


### External references
[1]: https://learn-elixir.dev/blogs/using-caching-to-speed-up-large-data-returns-by-1000x

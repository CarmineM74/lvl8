# CarmineGql

## TODO:
  - [x] Web API Speedup
  - [ ] Distributed Request Counter
        On top of this, we're going to change the request counter to work in a distributed environment, using one of the caching strategies we've talked about in the past week. 
        Figure out the different tradeoffs and leave a comment on why you chose the specific cache style in a module doc of the request counter. 
        For this cache part Redis and off-server caching isn't allowed.

        - PubSub
          - Easier to bootstrap
          - Even if some messages could be lost, for example due to partitioning, I believe that it would be no real issue for the intended purpose of the counters.
            Eventually they will catch up. If historical values are needed one could resort to telemetry.
          - The amount of data to be passed around between cluster's nodes, is very small. It's PubSub's overhead + counter values.
        
        - Tradeoffs considerations
          - write count 
          - read count 
          - how much consistency 
          - network portion 
          - node errors 
          - reboots 
          - multi layered?

  - [ ] Caching Telemetry
  - [ ] Testing: Make sure we have testing for our new caching systems

  - **Optional**: For extra credit you can try implementing a Singleton Cache that would be accessed in a distributed environment (meaning one node has the data and the rest pull it from that node, think about how you select which node holds the data), use this for the Distributed Request Counter

### Notes


### External references
[1]: https://learn-elixir.dev/blogs/using-caching-to-speed-up-large-data-returns-by-1000x

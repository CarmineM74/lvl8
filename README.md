# CarmineGql

## TODO:
  - [ ] Web API Speedup
    - To speed up our API and create a super quick API, we're going to cache all the data we can using the RequestCachePlug library. This article goes over the RequestCachePlug and why it's useful.

      We will create our own cache to use using Redis, and will need to use our skills from our lessons in Redis to create this Cache which should be used as the default cache for RequestCachePlug 
      which can be configured either in the config.ex or the middleware for our application. Don't forget that when you have a connection to redis, you have a single process managing the connection, 
      so we need to address this bottleneck!
      
  - [ ] Distributed Request Counter
  - [ ] Caching Telemetry
  - [ ] Testing: Make sure we have testing for our new caching systems

  - **Optional**: For extra credit you can try implementing a Singleton Cache that would be accessed in a distributed environment (meaning one node has the data and the rest pull it from that node, think about how you select which node holds the data), use this for the Distributed Request Counter

### Notes



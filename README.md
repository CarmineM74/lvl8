# CarmineGql

Resolve Counter Upgrade

In order to achieve a higher scale, we're going to need to upgrade our resolver counter, since it's happening on every request. How you do this is up to you, but it will need to be able to move much quicker than it can on one process. (We are not allowed to use any libraries for this)


## Solution

Use ETS to leverage read and write concurrency.
Migrate Counter agent to a GenServer facading an ETS table (Non blocking GenServer)


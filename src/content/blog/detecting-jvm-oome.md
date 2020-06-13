+++
title = "Detecting Java OutOfMemoryError before it happens"
date = 2018-09-25
aliases = [ "detecting-jvm-oome.html" ]
+++

Is it even possible, you might ask? Well, not really, we can't predict the future. But we _can_ detect the situation leading to `OutOfMemoryError`, lack of free heap memory, before it actually occurs. Technically there're other causes of OutOfMemoryError [described in detail here](https://docs.oracle.com/javase/8/docs/technotes/guides/troubleshoot/memleaks002.html) which are outside of the scope of the article and arguably less frequent and interesting.

Before moving forward, why can't we handle `java.lang.OutOfMemoryError` when it actually happens? The error is a `Throwable`, so we can catch it, right? Not quite. While technically the error can be caught there're very few cases when it's actually useful to do so. Because Java is a garbage collected language allocations of objects on the heap happens all the time as a part of the normal program execution, including when an exception is caught (e.g. to record the stack trace information). When a program runs out of memory all bets are off: any thread of the program can die at any time. You no longer can count on the application being in a sane state. "Impossible" things can happen. Okay, but at least the error will get logged? Unfortunately, that's not always true. Again, if a program has run out of memory you can't count on any operation to succeed. Writing a log, as everything else, allocates memory and can fail. As well as simply writing a message to the standard error output. This makes the error hard to detect.

If we can't do anything when an application runs out of memory, why should we care, can't we just let the application crash? One big reason is operability. Imagine getting an on-call alert about a web-service being slow. Or unresponsive. Or down. It's so much easier when you know that the service run out of memory rather than spending time in vain looking at the resource consumption graphs, garbage collector logs, application logs (hoping that a message about `OutOfMemoryError` was written to successfully).

Is detecting when an application runs out of memory _really_ that hard? There are already ways to monitor memory heap usage. So what's wrong with using that to detect when the program is running low on memory? Having all the memory used and having no memory available are different things in a garbage collected languages. At any point in time there will be objects in memory that are actually used alongside yet-to-be-collected garbage. `OutOfMemoryError` happens not when all the memory is used but when none can be claimed back after garbage collection.

To be more precise, there're two different ways to trigger an out of out of memory error when running low on heap memory: to try to allocate at once more memory than is available and to spend most of the time on garbage collection without being able to claim back much memory. The first one will happen for example if a program does things like allocating a large array and is usually easier to detect. `OutOfMemoryError` will be thrown by the call that requests allocation of a large chunk of memory and hence is trivial to track down. Also failing to get the requested memory doesn't necessarily mean that the whole program is screwed: monitoring system and logs should still be available. In practice it's more common to deal with the second type of out of memory condition: a program spending a high percentage of time (e.g. 99%) doing garbage collection but being able to claim less than a very low amount (e.g. 1%) of memory back. In this case an application will gradually (sometimes quite fast) come to a halt brining in all the complications described in the paragraphs above.

Is there any hope at all? Do not despair! There's a way to deal with the problem. And we don't even have to write a JVM agent in C (I'm sure that would be a fun exercise though). There're two quite different approaches to solve the problem of `OutOfMemoryError` detection. One is quite simple: it's possible to ask JVM to execute an external command with `-XX:OnOutOfMemoryError="<shell command>"` flag. It can be any program or script that's called after the program has run out of memory that will send an alert, update a metric or perform some other action. Because the command will be executed outside of JVM as a separate process, the approach do not suffer from the same pitfalls as trying to deal with the condition in the Java program itself. While it might not be as convenient to have a separate program to track OOME, it is a viable solution.

Wait, the title promised detecting OOME _before_ it happens? Here comes the second approach. The idea is quite simple: instead of measuring memory usage we measure how much memory is still occupied right after a garbage collection was performed. While it's not easy to get the number directly there's a way to get a notification when a predefined threshold is exceeded. It's achieved with [Java management API](https://docs.oracle.com/javase/10/docs/api/java/lang/management/package-summary.html) (also exposed via [JMX](https://docs.oracle.com/javase/10/docs/api/javax/management/package-summary.html)).

Before we continue it worth clarifying that in modern JVM all the heap memory is split into separate areas or "memory pools" for efficiency reasons. The pools are usually generational: created objects first end up in a pool for young generation, then survival generation eventually being placed into old or tenured generation if an object is still used after multiple collections. Split into generations and their number is dependent on a specific type of garbage collector used. When an OOME happens the tenured generation memory pool gets full. Why tenured pool specifically? Objects that are still needed move up in the hierarchy of generations until ending up in tenured generation. If an object is not used anymore it will be garbage collected and won't end up in the tenured memory pool (or will be removed from it). See [this great article](https://mechanical-sympathy.blogspot.com/2013/07/java-garbage-collection-distilled.html) for explanations how JVM heap is organized depending on what garbage collector is used. [VisualVM](https://visualvm.github.io) has an plugin called Visual GC which is an awesome way to see how a running application's heap looks like live.

So we're interested in being notified about running low on space in tenured generation memory pool. An interface for interacting with a JVM memory pool is provided by [`MemoreyPoolMXBean`](https://docs.oracle.com/javase/10/docs/api/java/lang/management/MemoryPoolMXBean.html). The bean for the pool we're interested in can be obtained by filtering the result of [`ManagementFactory.getMemoryPoolMXBeans()`](https://docs.oracle.com/javase/10/docs/api/java/lang/management/ManagementFactory.html#getMemoryPoolMXBeans\(\)). Firstly we're interested in heap memory pools and secondly in the one that supports usage threshold. Usage threshold is only supported for the tenured generation memory pool, the reason given in the documentation is [efficiency](https://docs.oracle.com/javase/10/docs/api/java/lang/management/MemoryPoolMXBean.html#UsageThreshold): young generation memory pools are intended for high frequency allocation of mostly short-lived objects and usage threshold has little meaning in this context. Without a further delay, below is the code to find the tenured generation `MemoryPoolMXBean`:

```java
MemoryPoolMXBean tenuredGen = ManagementFactory.getMemoryPoolMXBeans().stream()
    .filter(pool -> pool.getType() == MemoryType.HEAP)
    .filter(MemoryPoolMXBean::isUsageThresholdSupported)
    .findFirst()
    .orElseThrow(() -> new IllegalStateException(
        "Can't find tenured generation MemoryPoolMXBean"));
```

Now that we have access to the `MemoryPoolMXBean` setting a threshold for memory usage right after collection is simple:

```java
tenuredGen.setCollectionUsageThreshold(X);
```

X would be an absolute number in bytes. Note that size of a tenured memory pool is dependent on both heap and GC configuration so we need to set it to a value relative to a maximum size of the pool (the specific value of the threshold suitable for detection of out of memory situations will have to determined experimentally):

```java
double threshold = 0.99;
MemoryUsage usage = memoryPoolMxBean.getUsage();
memoryPoolMxBean.setCollectionUsageThreshold((int)Math.floor(usage.getMax()
        * threshold));
```

Now there are two ways to know if the threshold is exceeded: one is to poll a count with [`MemoryPoolMXBean.getCollectionUsageThresholdCount`](https://docs.oracle.com/javase/7/docs/api/java/lang/management/MemoryPoolMXBean.html#getCollectionUsageThresholdCount\(\)) and another is to subscribe to be notified every time the threshold is exceeded which is what's needed for our purpose:

```java
NotificationEmitter notificationEmitter =
        (NotificationEmitter) ManagementFactory.getMemoryMXBean();
notificationEmitter.addNotificationListener((notification, handback) -> {
        if (MemoryNotificationInfo.MEMORY_COLLECTION_THRESHOLD_EXCEEDED
                .equals(notification.getType())) {
            // Log, send an alert or whatever makes sense in your situation
            System.err.println("Running low on memory");
        }
    }, null, null);
```

So we've got a system in place to detect when a system approaches an out of memory error. There's a detail that needed to be dealt with for the solution to work correctly: JVM heap can grow and the tenured generation memory pool together with it making the set collection usage threshold incorrect. To mitigate the problem we can leverage memory pool usage threshold notifications which in themselves do not signify a problem as was explained above but will be triggered before collection threshold is exceeded. To set the threshold:

```java
memoryPoolMxBean.setUsageThreshold((int)Math.floor(usage.getMax() * threshold));
```

The notification listener for the memory pool can be extended to handle `MEMORY_THRESHOLD_EXCEEDED` notification type and update the thresholds.

The solution presented in the article is not perfect and it's important to understand its limitations. The two main ones I can think of are running out of memory early in the application startup before the heap monitoring is set up and `OutOfMemoryError` that is thrown when trying to allocate a large chunk of memory at once. The first one can be mitigated by making sure `LowHeapMemoryMonitor` is created early in the application life cycle. The second limitation can be hit when allocating a large array, for example. Both of the problems are usually possible to detect early on before the application is deployed to production. Another kind of issue possible to run into is when memory is consumed really fast: even if the notification about collection usage threshold exceeded is received the application can fail to react fast enough and run out of memory before the listener completes its work. If the action desired to take is not very quick and may require memory allocation on its own, like sending remote logs or an email, it might be wise to perform a low overhead operation first, e.g. write to `System.err`. In case you find the application to miss to take out of memory actions is might make sense to lower the collection threshold.

Credits

- [the StackOverflow question about the issue](https://stackoverflow.com/questions/11508310/detecting-out-of-memory-errors)

- [the article describing the idea](https://techblug.wordpress.com/2011/07/21/detecting-low-memory-in-java-part-2/). The solution presented in my article is basically the same but also handles dynamically growing heap.

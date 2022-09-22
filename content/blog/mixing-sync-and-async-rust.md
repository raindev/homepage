+++
title = "Mixing Sync and Async Rust"
date = 2022-09-15
aliases = [ "mixing-sync-and-async-rust.md" ]
+++

Recently I have read [JEP 426](https://openjdk.org/jeps/425), Java enhancement proposal introducing virtual threads - essentially a way to map multiple Java threads to a few operating system threads. I thought it's brilliant, especially the fact that the virtual threads could run _unmodified_ code.

Rust take a different approach to overcoming the scalability issues of operating system threads with asynchronous runtimes and async/await language support. One of the issues however is that the code has to be adapted for the asynchronous model. While async/await syntax significantly improves the experience of writing asynchronous code which is still straightforward to understand, mixing both styles of programming is still very annoying. Or is it really?

Let's look first at running an async function from a normal function. It's a common complaint that depending on a single async function "infects" the code and requires it to be asynchronous all the way. This is not quite the case. Execution an async function requires a runtime and here's how we get one that will run code on the caller thread:

```rust
let runtime = tokio::runtime::Builder::new_current_thread()
    .enable_all()
    .build()?
```

Now running an async function is quite simple:

```rust
let result = runtime.block_on(my_async_function);
```

Instead of [`new_current_thread`](https://docs.rs/tokio/latest/tokio/runtime/struct.Builder.html#method.new_current_thread) we could use [`new_multi_thread`](https://docs.rs/tokio/latest/tokio/runtime/struct.Builder.html#method.new_multi_thread) to get a thread pool runtime that allows to run tasks asynchronously with [`Runtime::spawn`](https://docs.rs/tokio/latest/tokio/runtime/struct.Runtime.html#method.spawn) and wait for the completion of tasks with [`Runtime::block_on`](https://docs.rs/tokio/latest/tokio/runtime/struct.Runtime.html#method.block_on).

Alright, this wasn't too bad. What about running synchronous code from an async function? A simple function that does data transformation could be run without any fuss. The problem is code either doing blocking IO or CPU intensive computations as it would block one of the runtime threads and reduce the capacity available to execute async tasks. Thankfully the solution is straightforward:

```rust
let resutl = task::spawn_blocking(|| my_slow_http_call()).await?;
```

[`spawn_blocking`](https://docs.rs/tokio/1.21.1/tokio/task/fn.spawn_blocking.html) would execute the task using a dynamically sized thread pool dedicated to blocking tasks.

While it's not the same as being able to run the same code with blocking/asynchronous runtime, mixing the two approaches is not too difficult. If you want to read more on the topic I suggest [the Tokio tutorial on bridging with sync code](https://tokio.rs/tokio/topics/bridging).

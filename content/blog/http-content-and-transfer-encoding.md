+++
title = "Content-Encoding and Transfer-Encoding HTTP Headers"
date = 2024-03-19
+++

An HTTP message comprises a request line (a request method, an URL and a protocol version) or status line (a protocol version and a response status code) followed by a list of headers and a message body separated with an empty line. The request/status line and the headers are plain text, while the message body can be any content (specified by `Content-Type`), including binary, optionally encoded.

How the message body is encoded is described by two headers: `Transfer-Encoding` and `Content-Encoding`. Compression and chunked transfer encoding are two main reasons behind encoding the message body. The goal of compression is to improve the performance by reducing the amount of data transferred, although it does impose additional work for the server and the client. With chunked transfer coding a large message body is broken down into chunks transferred separately. This enables piece by piece data transfer, sending messages where the size is not known ahead of time and streaming of large media.

Although the HTTP specification permits the use of compression with either of the headers, in practice the only widely supported option of `Transfer-Encoding` is `chunked` while compression is implemented using `Content-Encoding` header.

Chunked coding splits the message body into hunks separated with newlines and preceded with length and some optional metadata. It also supports trailers - think headers sent _after_ the message body. Here is an example (all newlines are `\r\n`):

```http
GET /greetings HTTP/1.1
Host: example.com
Transfer-Encoding: chunked

5; comment="first chunk"
hello
5; comment="second chunk"
world
0
Signature: signed
```

`Transfer-Encoding` is applied on the message level and specifies how the body should be transferred, while being largely transparent to the application code. This allows intermediate HTTP proxies to modify the encoding before forwarding the message. Typically, an HTTP server framework or client library will reconstruct the body before handing it over to the application code or break it down into chunks before transmission. `Transfer-Encoding` requires `Content-Length` to be omitted.

`Content-Encoding` refers to the representation of the message body payload and specifies the compression algorithm used. It requires a server/client to explicitly compress/decompress the body when it's sent/received. `Content-Length` in such a case refers to the encoded content. Content encoding is expected to be preserved by HTTP proxies.

Both headers could be used together, in such a case the body is first compressed with the algorithm specified by `Content-Encoding` and then split into chunks.

A client can declare the preferred transfer encoding via `TE` header (e.g. to announce support for trailers), although chunked coding is always supported. `Accept-Encoding` plays the same role for content encoding.

Note that `Transfer-Encoding` is not supported by HTTP/2 and HTTP/3, which employ a different mechanism for streaming based on splitting data into frames.

## Go standard library

The only transfer encoding supported by `net/http` client/server is `chunked` ([ref](https://github.com/golang/go/blob/3c78ace24f3aa025a72b53be3b83423f9f24ee5d/src/net/http/transfer.go#L649-L651)). As expected requests/responses are read ([ref](https://github.com/golang/go/blob/3c78ace24f3aa025a72b53be3b83423f9f24ee5d/src/net/http/transfer.go#L563-L568)) and written ([ref](https://github.com/golang/go/blob/3c78ace24f3aa025a72b53be3b83423f9f24ee5d/src/net/http/transfer.go#L563-L568)) in chunked encoding transparently. The client sends a chunked request when necessary, i.e. `Content-Lenght` is unknown ([ref](https://github.com/golang/go/blob/3c78ace24f3aa025a72b53be3b83423f9f24ee5d/src/net/http/transfer.go#L169)).

A server implemented with `net/http` has to deal with `Content-Encoding` compression explicitly. The client on the other hand requests `gzip` compression by default ([ref](https://github.com/golang/go/blob/3c78ace24f3aa025a72b53be3b83423f9f24ee5d/src/net/http/transport.go#L2612-L2630)), and decompresses the response transparently ([ref](https://github.com/golang/go/blob/3c78ace24f3aa025a72b53be3b83423f9f24ee5d/src/net/http/transport.go#L2244-L2245)), unless a different `Content-Encoding` is specified.

## References

A brief overview at MDN:

- [Transfer-Encoding](https://developer.mozilla.org/docs/Web/HTTP/Headers/Transfer-Encoding)
- [Content-Encoding](https://developer.mozilla.org/docs/Web/HTTP/Headers/Content-Encoding)

For more details see some of the fresh RFCs on HTTP, they're actually very readable with clear examples:

- [RFC 9110 - HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110)
- [RFC 9112 - HTTP/1.1](https://www.rfc-editor.org/rfc/rfc9112)

---

_Update 2024-03-24: correct the statement that content and transfer encoding are mutually exclusive and fix the example of a chunked coding by removing the superfluous newlines._

# Memory

This benchmark was prepared to analyse a behaviour, where we have 400k of encoded buffers that are ~500b in size each and decoding them takes 3.5gb of memory (according to benchee).

## Run

To run this benchmark you need to ...

* `cd bench_memory`
* run `protoc --elixir_out=./lib ./proto/test.proto`
* run `mix run script/bench.exs`

## Analysis

First we are preparing batches of data to process.

Every entity in these batches is an `Event` (like in a calendar; take a look at test.proto).

The size of the batches varies by the size of the event and the number of events.

The first batch has one event of size 1 (256 bytes) in it.

The other batches are a multiple of 10 (both in size and number of events).

```
1/1 - event: 256
1/1 - event_encoded: 48
1/1 - event_decoded: 256
1/1 - events_encoded: 64
1/1 - events_decoded: 272

1/10 - event: 256
1/10 - event_encoded: 48
1/10 - event_decoded: 256
1/10 - events_encoded: 640
1/10 - events_decoded: 2720

40/1 - event: 2752
40/1 - event_encoded: 48
40/1 - event_decoded: 2752
40/1 - events_encoded: 64
40/1 - events_decoded: 2768

40/10 - event: 2752
40/10 - event_encoded: 48
40/10 - event_decoded: 2752
40/10 - events_encoded: 640
40/10 - events_decoded: 27680

400/1 - event: 25792
400/1 - event_encoded: 48
400/1 - event_decoded: 25792
400/1 - events_encoded: 64
400/1 - events_decoded: 25808

4000/1 - event: 256192
4000/1 - event_encoded: 48
4000/1 - event_decoded: 256192
4000/1 - events_encoded: 64
4000/1 - events_decoded: 256208

1/100 - event: 256
1/100 - event_encoded: 48
1/100 - event_decoded: 256
1/100 - events_encoded: 6400
1/100 - events_decoded: 27200

1/1000 - event: 256
1/1000 - event_encoded: 48
1/1000 - event_decoded: 256
1/1000 - events_encoded: 64000
1/1000 - events_decoded: 272000
```

The first two tests encode and decode the smaller batches.

The main take-a-ways here are ...

* decoding a 256b event takes 1.5kb of main memory
* decoding 10 of these takes 10 times the memory

... more on this further down.

```
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz
Number of Available Cores: 8
Available memory: 15.33 GB
Elixir 1.8.1
Erlang 22.0.7

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 36 s

Benchmarking encode 1-1...
Benchmarking encode 1-10 ...
Benchmarking encode 10-1...
Benchmarking encode 10-10...

Name                   ips        average  deviation         median         99th %
encode 1-1        417.31 K        2.40 μs   ±757.46%        1.99 μs        2.91 μs
encode 10-1        85.76 K       11.66 μs   ±140.85%        8.88 μs      131.26 μs
encode 1-10        48.14 K       20.77 μs    ±55.07%       18.98 μs       52.47 μs
encode 10-10        7.77 K      128.73 μs    ±17.98%      124.28 μs      197.64 μs

Comparison:
encode 1-1        417.31 K
encode 10-1        85.76 K - 4.87x slower +9.26 μs
encode 1-10        48.14 K - 8.67x slower +18.37 μs
encode 10-10        7.77 K - 53.72x slower +126.34 μs

Memory usage statistics:

Name            Memory usage
encode 1-1           1.24 KB
encode 10-1          7.34 KB - 5.91x memory usage +6.09 KB
encode 1-10         12.42 KB - 10.00x memory usage +11.18 KB
encode 10-10        73.36 KB - 59.06x memory usage +72.12 KB

**All measurements for memory usage were the same**
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz
Number of Available Cores: 8
Available memory: 15.33 GB
Elixir 1.8.1
Erlang 22.0.7

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 36 s

Benchmarking decode 1-1...
Benchmarking decode 1-10...
Benchmarking decode 10-1...
Benchmarking decode 10-10...

Name                   ips        average  deviation         median         99th %
decode 1-1        602.73 K        1.66 μs  ±1060.69%        1.53 μs        2.50 μs
decode 10-1       116.51 K        8.58 μs    ±74.03%        8.20 μs       12.30 μs
decode 1-10        67.28 K       14.86 μs    ±19.95%       14.61 μs       21.83 μs
decode 10-10       11.67 K       85.72 μs     ±7.31%       84.78 μs      104.93 μs

Comparison:
decode 1-1        602.73 K
decode 10-1       116.51 K - 5.17x slower +6.92 μs
decode 1-10        67.28 K - 8.96x slower +13.20 μs
decode 10-10       11.67 K - 51.67x slower +84.06 μs

Memory usage statistics:

Name            Memory usage
decode 1-1           1.55 KB
decode 10-1         10.45 KB - 6.72x memory usage +8.89 KB
decode 1-10         15.55 KB - 10.00x memory usage +13.99 KB
decode 10-10       112.47 KB - 72.34x memory usage +110.91 KB

**All measurements for memory usage were the same**
```

Now let's find out, if/how the memory usage scales with the size of the event (for decoding).

We are running 4 tests with 4 batches of one event. Every event is 10 times bigger than the previous one.

The main take-a-ways are ...

* memory usage scales linear with a factor of 1.5 for the size of the event (10 time bigger event, needs 1.5 times the memory)
* for events of size 256b we get 1.5kb main mem usage. For an event of 500b we get (roughly) 2.6kb of main mem usage per event (we measured/verified this)

```
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz
Number of Available Cores: 8
Available memory: 15.33 GB
Elixir 1.8.1
Erlang 22.0.7

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 36 s

Benchmarking decode 1-1...
Benchmarking decode 10-1...
Benchmarking decode 100-1...
Benchmarking decode 1000-1...

Name                    ips        average  deviation         median         99th %
decode 1-1         605.67 K        1.65 μs  ±1081.20%        1.49 μs        2.46 μs
decode 10-1        118.94 K        8.41 μs    ±66.95%        8.18 μs       11.87 μs
decode 100-1        13.13 K       76.13 μs     ±9.18%       77.10 μs       95.91 μs
decode 1000-1        1.10 K      911.63 μs     ±5.95%      912.07 μs     1042.04 μs

Comparison:
decode 1-1         605.67 K
decode 10-1        118.94 K - 5.09x slower +6.76 μs
decode 100-1        13.13 K - 46.11x slower +74.48 μs
decode 1000-1        1.10 K - 552.15x slower +909.98 μs

Memory usage statistics:

Name             Memory usage
decode 1-1            1.55 KB
decode 10-1          10.45 KB - 6.72x memory usage +8.89 KB
decode 100-1         87.66 KB - 56.39x memory usage +86.11 KB
decode 1000-1       832.41 KB - 535.42x memory usage +830.86 KB

**All measurements for memory usage were the same**
```

Now we look at how we scale with the number of events.

The main take-aways are ...

* we scale linear with a factor of 10 (means to process 10 times more events we need 10 times more memory)

```
Operating System: Linux
CPU Information: Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz
Number of Available Cores: 8
Available memory: 15.33 GB
Elixir 1.8.1
Erlang 22.0.7

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 36 s

Benchmarking decode 1-1...
Benchmarking decode 1-10...
Benchmarking decode 1-100...
Benchmarking decode 1-1000...

Name                    ips        average  deviation         median         99th %
decode 1-1         607.78 K        1.65 μs  ±1079.29%        1.50 μs        2.32 μs
decode 1-10         67.42 K       14.83 μs    ±43.34%       14.62 μs       18.97 μs
decode 1-100         6.72 K      148.75 μs     ±5.25%      148.02 μs      169.59 μs
decode 1-1000        0.58 K     1710.20 μs     ±4.67%     1697.06 μs     1940.64 μs

Comparison:
decode 1-1         607.78 K
decode 1-10         67.42 K - 9.02x slower +13.19 μs
decode 1-100         6.72 K - 90.41x slower +147.11 μs
decode 1-1000        0.58 K - 1039.42x slower +1708.56 μs

Memory usage statistics:

Name             Memory usage
decode 1-1            1.55 KB
decode 1-10          15.55 KB - 10.00x memory usage +13.99 KB
decode 1-100        155.47 KB - 100.00x memory usage +153.91 KB
decode 1-1000      1554.69 KB - 1000.00x memory usage +1553.13 KB

**All measurements for memory usage were the same**
```

### Summary

With the numbers and behavior we have we should see a main mem usage of ...

`2.5kb * 400k ~ 1gb`

... but we see `3.6gb`.
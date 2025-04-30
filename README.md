# real-time-flink-analytics
Use flink for streaming analytics through orderbook data generator from repo: https://github.com/AdrienLibert/orderbook
The above repo has been built together with @[AdrienLibert](https://github.com/AdrienLibert)

This project is about using flink for streaming analytics. The streaming job is creating OHLC data from order simulated from orderbook (conjointly worked on the project).

Flink is a powerful tool fitting the situation pretty well. In this streaming job we use mainly the sql flink api and let flink manages the internal states of the data.

# Install

## Dependencies

Kafka
```
make helm
make start_kafka
```


Trade & Orderbook generator [orderbook](https://github.com/AdrienLibert/orderbook). Assuming the repo is cloned in the same parent folder:
```
make build_orderbook
make start_orderbook
```
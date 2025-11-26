from flask import Flask
from prometheus_client import start_http_server, Summary

app = Flask(__name__)

REQUEST_TIME = Summary('hello_world_request_processing_seconds', 'Time spent processing hello world requests')

@app.route('/', methods=['GET'])
@REQUEST_TIME.time()
def home():
    return "Hello World! Prometheus metrics can be viewed at :8000/metrics"

if __name__ == '__main__':
    start_http_server(8000)
    app.run(host='0.0.0.0', port=8080)
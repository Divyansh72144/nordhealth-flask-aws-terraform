from flask import Flask, request
from prometheus_client import Summary, generate_latest, CONTENT_TYPE_LATEST
from flask import Response

app = Flask(__name__)

REQUEST_TIME = Summary('hello_world_request_processing_seconds', 'Time spent processing hello world requests')

@app.route('/', methods=['GET'])
@REQUEST_TIME.time()
def home():
    metrics_url = f"/metrics"
    return (
        'Hello World!<br>'
        f'<a href="{metrics_url}" target="_blank">Click here to view Prometheus metrics</a>'
    )

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
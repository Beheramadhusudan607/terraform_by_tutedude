from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello from Flask Backend! (Port 5000)'

if __name__ == '__main__':
    # Flask runs on 0.0.0.0 for external access
    app.run(host='0.0.0.0', port=5000)
import requests
import numpy as np
import json
import random
host = "http://127.0.0.1:8080"
names = ["Joe", "Neo", "Sam"]

for _ in range(20):
    feature = np.random.randn(150)
    data = {'feature': feature.tolist(), 'label': random.choice(names), 'dsid': 0}
    data_str = json.dumps(data)
    response = requests.post(host + '/AddDataPoint',data=data_str.encode())
    content = response.content.decode()
    print(content)
                             
response = requests.get(host + '/UpdateModel?dsid=0')
content = response.content.decode()
print(content)

feature = np.random.randn(150)
data = {'feature': feature.tolist(), 'dsid': 0}
data_str = json.dumps(data)
response = requests.post(host + '/PredictOne?model_name=KNN',data=data_str.encode())
content = response.content.decode()
print(content)
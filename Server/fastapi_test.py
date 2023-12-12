import requests
import numpy as np
import json
import random
from urllib.parse import quote as urlquote
host = "http://127.0.0.1:8080"
#names = ["Joe", "Neo", "Sam"]




# response = requests.post(host + '/EZGenerate?text=1&src_lang=en&tar_lang=cn&debug=True',data=b'')
# with open('Server/audio/dummyFromServer.wav', 'wb') as fwb:
#     fwb.write(response.content)

with open('Server/audio/chinese.mp3', 'rb') as f:
    data = f.read()
text = urlquote("How are you today?")
response = requests.post(f'{host}/EZGenerate?text={text}&src_lang=en&tar_lang=zh&debug=False',data=data)
with open('Server/audio/TestResult.wav', 'wb') as fwb:
    fwb.write(response.content)
    

# for _ in range(20):
#     feature = np.random.randn(150)
#     data = {'feature': feature.tolist(), 'label': random.choice(names), 'dsid': 0}
#     data_str = json.dumps(data)
#     response = requests.post(host + '/AddDataPoint',data=data_str.encode())
#     content = response.content.decode()
#     print(content)
                             
# response = requests.get(host + '/UpdateModel?dsid=0')
# content = response.content.decode()
# print(content)

# feature = np.random.randn(150)
# data = {'feature': feature.tolist(), 'dsid': 0}
# data_str = json.dumps(data)
# response = requests.post(host + '/PredictOne?model_name=KNN',data=data_str.encode())
# content = response.content.decode()
# print(content)
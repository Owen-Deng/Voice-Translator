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
response = requests.post(f'{host}/EZGenerate?text={text}&src_lang=en&tar_lang=zh&debug=false',data=data)
with open('Server/audio/TestResult.wav', 'wb') as fwb:
    fwb.write(response.content)

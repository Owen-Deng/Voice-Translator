import time
from speechbrain.pretrained import EncoderClassifier

# detect language, return language code, if lang1 and lang2 are specified,
# return the most confident one
def detect(audio, lang_code1 = None, lang_code2 = None):
    prediction = language_id.classify_file(audio)
    if lang_code1 and lang_code2 and lang_code1 in lang_map and lang_code2 in lang_map:
        idx_lang1 = lang_map[lang_code1]
        idx_lang2 = lang_map[lang_code2]
        if prediction[0][0,idx_lang1] >= prediction[0][0,idx_lang2]:
            return lang_code1
        else:
            return lang_code2
        
    return prediction[3][0].split(':',1)[0]



# return mapping from lang_code to prediction index example: {'zh':106, 'ja': 45}
def read_lang_index(label_encoder):
    with open(label_encoder, 'r') as label_encoder_file:
        index_text = label_encoder_file.read().splitlines()
    
    lang_map = {}
    for idx, index_text_line in enumerate(index_text):
        tmp = index_text_line.split(':', 1)
        lang_map[tmp[0][1:]] = idx
    return lang_map
    

if __name__ == "__main__":
    start_time = time.time()
    run_opts = {"device":"cuda"}
    # https://huggingface.co/speechbrain/lang-id-voxlingua107-ecapa
    language_id = EncoderClassifier.from_hparams(source="speechbrain/lang-id-voxlingua107-ecapa", savedir="Server/langdetect_model", run_opts = run_opts)
    lang_map = read_lang_index("Server/langdetect_model/label_encoder.txt")
    detect("Server/audio/chinese.mp3", 'zh', 'ja') # warm up
    print(f"language detection model loaded. {time.time() - start_time:.2f}")
    
    ## testing code
    start_time = time.time()
    for i in range(10):
        s = time.time()
        lang = detect("Server/audio/chinese.mp3", 'zh', 'ja')
        print(f"{time.time() - s:.2f}, {lang}")
    print(f"total time: {time.time() - start_time:.2f}")
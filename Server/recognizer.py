import time
import torch
from transformers import AutoModelForSpeechSeq2Seq, AutoProcessor, pipeline

def recognize(audio) -> str:
    result = pipe("Server/audio/chinese.mp3")
    return result['text']
    

if __name__ == "__main__":
    start_time = time.time()
    device = "cuda:0" if torch.cuda.is_available() else "cpu"
    torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32

    model_id = "openai/whisper-large-v3"

    model = AutoModelForSpeechSeq2Seq.from_pretrained(
        model_id, torch_dtype=torch_dtype, low_cpu_mem_usage=True, use_safetensors=True
    )
    model.to(device)

    processor = AutoProcessor.from_pretrained(model_id)

    pipe = pipeline(
        "automatic-speech-recognition",
        model=model,
        tokenizer=processor.tokenizer,
        feature_extractor=processor.feature_extractor,
        max_new_tokens=128,
        chunk_length_s=30,
        batch_size=16,
        return_timestamps=False,
        torch_dtype=torch_dtype,
        device=device,
    )
    # warm up
    recognize("Server/audio/chinese.mp3")
    print(f"language recognition model loaded. {time.time() - start_time:.2f}")
    
    ## testing code
    start_time = time.time()
    for i in range(10):
        s = time.time()
        lang = recognize("Server/audio/chinese.mp3")
        print(f"{time.time() - s:.2f}, {lang}")
    print(f"total time: {time.time() - start_time:.2f}")


import os
import io
import tempfile
from threading import Thread
import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import  Response
from generator import generate, get_conditioning_latents, load as generator_load
from translator import translate, load as translator_load
#from langdetector import detect, load as langdetector_load

app = FastAPI()

@app.post("/EZGenerate")
async def EZGenerate(request: Request, text, src_lang, tar_lang, debug='false'):
    '''Save data point and class label to database
    '''
    if debug == 'true':
        # return dummy audio if in debug mode
        with open("Server/audio/dummy.wav", 'rb') as frb:
            return Response(frb.read(), media_type="audio/wav")

    
    data = await request.body()
    audio_path = os.path.join(tempfile.gettempdir(), 'tmp.wav')
    with open(audio_path, 'wb') as fa:
        fa.write(data)
    
    # translate
    translatedText, res = translate(text, src_lang, tar_lang)
    if res:
        return
    
    # voice feature extraction
    gpt_cond_latent, speaker_embedding = get_conditioning_latents(audio_path)
    
    # remove tmp file
    try:
        os.remove(audio_path)
    except:
        pass
    
    # generate audio
    output = io.BytesIO()
    generate(translatedText, tar_lang, gpt_cond_latent, speaker_embedding, output)
    return Response(output.read(), media_type="audio/wav")


if __name__ == "__main__":
    # load model in parallel
    t1 = Thread(target=generator_load)
    t1.start()
    
    t2 = Thread(target=translator_load)
    t2.start()
    
    # t3 = Thread(target=langdetector_load) # langdetector is disabled
    # t3.start()
    
    t1.join()
    t2.join()
    #t3.join()
    
    db = client.audios
    uvicorn.run(app, host="0.0.0.0", port=8080)
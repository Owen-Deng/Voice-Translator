from TTS.tts.configs.xtts_config import XttsConfig
from TTS.tts.models.xtts import Xtts
import torchaudio
import torch
import torch.nn.functional as F
import time


def get_conditioning_latents(audio_path):
    gpt_cond_latent, speaker_embedding = model.get_conditioning_latents(
            audio_path=audio_path,
            gpt_cond_len=conditioning_latents_settings["gpt_cond_len"],
            gpt_cond_chunk_len=conditioning_latents_settings["gpt_cond_chunk_len"],
            max_ref_length=conditioning_latents_settings["max_ref_len"],
            sound_norm_refs=conditioning_latents_settings["sound_norm_refs"],
        )
    return gpt_cond_latent, speaker_embedding

@torch.inference_mode()
def generate(text, language, gpt_cond_latent, speaker_embedding, output) -> str:
    # GPT inference
    do_sample=True
    num_beams=1
    speed=1.0
    language = language.split("-")[0]  # remove the country code
    length_scale = 1.0 / max(speed, 0.05)
    sent = text.strip().lower()
    text_tokens = torch.IntTensor(model.tokenizer.encode(sent, lang=language)).unsqueeze(0).to(model.device)
    
    if text_tokens.shape[-1] >= model.args.gpt_max_text_tokens:
        #return "XTTS can only generate text with a maximum of 400 tokens."
        return "Text too long."
    
    with torch.no_grad():
        gpt_codes = model.gpt.generate(
            cond_latents=gpt_cond_latent,
            text_inputs=text_tokens,
            input_tokens=None,
            do_sample=do_sample,
            top_p=inference_settings["top_p"], 
            top_k=inference_settings["top_k"],
            temperature=inference_settings["temperature"],
            num_return_sequences=model.gpt_batch_size,
            num_beams=num_beams,
            length_penalty=inference_settings["length_penalty"],
            repetition_penalty=inference_settings["repetition_penalty"],
            output_attentions=False
        )
        expected_output_len = torch.tensor(
            [gpt_codes.shape[-1] * model.gpt.code_stride_len], device=text_tokens.device
        )

        text_len = torch.tensor([text_tokens.shape[-1]], device=model.device)
        gpt_latents = model.gpt(
            text_tokens,
            text_len,
            gpt_codes,
            expected_output_len,
            cond_latents=gpt_cond_latent,
            return_attentions=False,
            return_latent=True,
        )

        if length_scale != 1.0:
            gpt_latents = F.interpolate(
                gpt_latents.transpose(1, 2), scale_factor=length_scale, mode="linear"
            ).transpose(1, 2)

        wav = model.hifigan_decoder(gpt_latents, g=speaker_embedding)
        wav = torch.reshape(wav, (1,-1)).cpu()
        
        torchaudio.save(output, wav, 24000, format = "wav")
        output.seek(0)
        
    return ""

    # outputs = model.inference(
    #         text,
    #         language,
    #         gpt_cond_latent,
    #         speaker_embedding,
    #         **inference_settings
    #     )
    # wav = torch.tensor(outputs['wav']).unsqueeze(0)
    # torchaudio.save(output_path, wav, 24000)

def load():
    global model, conditioning_latents_settings, inference_settings
    start_time = time.time()
    config = XttsConfig()
    config.load_json("Server/XTTS-v2/config.json")
    model = Xtts.init_from_config(config)
    model.load_checkpoint(config, checkpoint_dir="Server/XTTS-v2/", eval=True)
    model.cuda()

    conditioning_latents_settings = {
        "gpt_cond_len": config.gpt_cond_len,
        "gpt_cond_chunk_len": config.gpt_cond_chunk_len,
        "max_ref_len": config.max_ref_len,
        "sound_norm_refs": config.sound_norm_refs,
    }
    inference_settings = {
                "temperature": config.temperature,
                "length_penalty": config.length_penalty,
                "repetition_penalty": config.repetition_penalty,
                "top_k": config.top_k,
                "top_p": config.top_p
            }
    print(f"XTTS model loaded! {time.time()-start_time:.2f}")

if __name__ == "__main__":
    load()
    ## testing code
    audio_path=r"Server/audio/chinese.mp3"
    output_path = r"result.wav"
    text = "This is a test for voice generation."
    start_time = time.time()
    gpt_cond_latent, speaker_embedding = get_conditioning_latents(audio_path)
    print(f"gpt_cond_latent generated! {time.time()-start_time:.2f}")
    for _ in range(10):
        s = time.time()
        import io
        buffer = io.BytesIO()
        generate(text, "en", gpt_cond_latent, speaker_embedding, buffer)
        with open("result.wav", 'wb') as f:
            f.write(buffer.getbuffer())
        print(f"{time.time() - s:.2f}")
    print(f"total time: {time.time()-start_time:.2f}")
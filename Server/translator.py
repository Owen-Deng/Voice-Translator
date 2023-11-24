import argostranslate.package
import argostranslate.translate
import time
#import os
#os.environ["ARGOS_DEVICE_TYPE"] = "cuda"

def translate(text, source_lang, target_lang):
    if (source_lang, target_lang) not in supported:
        return "", f"translation form {source_lang} to {target_lang} is not supported"
    
    if (source_lang, target_lang) not in installed:
        argostranslate.package.install_from_path(supported[(source_lang, target_lang)].download())
        installed.add((source_lang, target_lang))
    
    translatedText = argostranslate.translate.translate(text, source_lang, target_lang)
    return translatedText, ""

def get_languages():
    res = []
    for pkg in supported.values():
        res.append({"srcname": pkg.from_name,
                    "tarname": pkg.to_name,
                    "src": pkg.from_code,
                    "tar": pkg.to_code})
    
    return res

if __name__ == "__main__":
    
    start_time = time.time()
    argostranslate.package.update_package_index()
    
    supported = argostranslate.package.get_available_packages()
    supported = {(pkg.from_code, pkg.to_code):pkg for pkg in supported}
    
    installed = argostranslate.package.get_installed_packages()
    installed = set([(pkg.from_code, pkg.to_code) for pkg in installed])
    
    # warm up
    translate("warm up", 'en', 'zh')
    
    print(f"Translation model loaded!{time.time() - start_time:.2f}")
    
    ## testing code
    text = """We end today's show looking at how Israel's 47-day bombardment has left Gaza in ruins. 
Satellite images show the Israeli attacks have left about half of all buildings in northern Gaza damaged or destroyed since October 7th. 
Overall, researchers say at least 56,000 buildings in Gaza have been damaged.
We’re joined now by two researchers who lead the Decentralized Damage Mapping Group, a network of satellite image scientists using remote sensing to analyze and map the damage and destruction in the Gaza Strip. 
Corey Scher is a doctoral researcher at CUNY, the CUNY Graduate Center here in New York, and Jamon Van Den Hoek is an associate professor of geography at Oregon State University, the lead of the Conflict Ecology group.
Jamon, let’s begin with you. Explain what you found in these charts, these images that you have of Gaza, where it stands today, where it stood a month ago."""

    from_lang = 'en'
    to_lang = 'zh'
    
    # Translate
    for t in text.splitlines():
        start = time.time()
        translatedText, msg = translate(t, from_lang, to_lang)
        print(f"{time.time() - start:.2f}, {translatedText}")